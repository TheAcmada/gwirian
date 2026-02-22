class FeaturesController < ApplicationController
  before_action :require_workspace
  before_action :set_project
  before_action :set_feature, only: [ :show, :update, :destroy, :add_tag, :remove_tag, :start_execution, :select_scenarios, :execute_scenarios ]

  def index
    if params[:q].present?
      @features = Feature.search_by_project(params[:q], @project.id).records.order(:title).includes(scenarios: :scenario_executions)
    else
      @features = @project.features.order(:title).includes(scenarios: :scenario_executions)
    end
  end

  def show
    features_ordered = @project.features.order(:title).to_a
    index = features_ordered.index(@feature)
    if index && features_ordered.size > 1
      @prev_feature = index.positive? ? features_ordered[index - 1] : features_ordered.last
      @next_feature = index < features_ordered.size - 1 ? features_ordered[index + 1] : features_ordered.first
    else
      @prev_feature = nil
      @next_feature = nil
    end
    if htmx_request?
      response.headers["HX-Prev-Feature-Url"] = project_feature_path(@project, @prev_feature) if @prev_feature.present?
      response.headers["HX-Next-Feature-Url"] = project_feature_path(@project, @next_feature) if @next_feature.present?
    end
  end

  def create
    @feature = @project.features.new(title: "New feature")
    authorize! :create, @feature

    if @feature.save
      redirect_to project_feature_path(@project, @feature), notice: "Feature created successfully"
    else
      redirect_to project_features_path(@project), alert: "Failed to create feature"
    end
  end

  def update
    authorize! :update, @feature

    if @feature.update(feature_params)
      if htmx_request?
        render Features::HeaderComponent.new(feature: @feature, project: @project), layout: false
      else
        redirect_to project_feature_path(@project, @feature), notice: "Feature updated successfully"
      end
    else
      if htmx_request?
        render Features::HeaderComponent.new(feature: @feature, project: @project), layout: false, status: :unprocessable_entity
      else
        render :show, status: :unprocessable_entity
      end
    end
  end

  def destroy
    authorize! :destroy, @feature

    @feature.destroy

    if htmx_request?
      @features = @project.features.order(:title)
      render partial: "features/features", locals: { features: @features, project: @project, notice: "Feature deleted successfully" }
    else
      redirect_to project_features_path(@project), notice: "Feature deleted successfully"
    end
  end

  def add_tag
    authorize! :update, @feature

    tag_name = params[:tag_name]&.strip
    if valid_tag_name?(tag_name)
      @feature.tag_list.add(tag_name)
      @feature.save
    end

    if htmx_request?
      render Features::HeaderComponent.new(feature: @feature.reload, project: @project), layout: false
    else
      redirect_to project_feature_path(@project, @feature)
    end
  end

  def remove_tag
    authorize! :update, @feature

    tag_name = params[:tag_name]&.strip
    if valid_tag_name?(tag_name)
      @feature.tag_list.remove(tag_name)
      @feature.save
    end

    if htmx_request?
      render Features::HeaderComponent.new(feature: @feature.reload, project: @project), layout: false
    else
      redirect_to project_feature_path(@project, @feature)
    end
  end

  def start_execution
    authorize! :execute, @feature
    redirect_to select_scenarios_project_feature_path(@project, @feature)
  end

  def select_scenarios
    authorize! :execute, @feature

    if request.get?
      @scenarios = @feature.scenarios.order(:position).includes(:scenario_executions)
    elsif request.post?
      selected_ids = params[:scenario_ids] || []
      scenario_ids = selected_ids.map(&:to_i)

      # Validate that all scenario IDs belong to this feature
      valid_scenario_ids = @feature.scenarios.where(id: scenario_ids).pluck(:id)
      session[:selected_scenario_ids] = valid_scenario_ids
      redirect_to execute_scenarios_project_feature_path(@project, @feature)
    end
  end

  def execute_scenarios
    authorize! :execute, @feature

    if request.get?
      selected_ids = session[:selected_scenario_ids] || []
      @scenarios = @feature.scenarios.where(id: selected_ids).order(:position).includes(:scenario_executions)
      @scenarios = @scenarios.to_a.sort_by { |s| selected_ids.index(s.id) }
    elsif request.post?
      executions_data = execution_params
      run_tag_list = params[:tag_list].to_s.strip.presence
      executed_count = 0

      # Validate that all scenario IDs belong to this feature
      scenario_ids = executions_data.keys.map(&:to_i)
      valid_scenario_ids = @feature.scenarios.where(id: scenario_ids).pluck(:id).map(&:to_s)

      executions_data.each do |scenario_id, execution_data|
        # Skip if scenario doesn't belong to this feature
        next unless valid_scenario_ids.include?(scenario_id.to_s)

        scenario = @feature.scenarios.find_by(id: scenario_id)
        next unless scenario

        status = execution_data[:status]
        notes = execution_data[:notes]
        next unless status.present? && %w[passed failed].include?(status)

        execution = ScenarioExecution.new(
          scenario: scenario,
          user: Current.user,
          status: status,
          notes: notes,
          executed_at: Time.current
        )
        execution.tag_list = run_tag_list if run_tag_list.present?
        execution.save!
        executed_count += 1
      end

      session.delete(:selected_scenario_ids)
      redirect_to project_feature_path(@project, @feature), notice: "#{executed_count} scenario(s) executed successfully"
    end
  end

  private

  def set_project
    @project = workspace_projects.find(params[:project_id])
  end

  def set_feature
    @feature = @project.features.includes(scenarios: :scenario_executions).find(params[:id])
  end

  def feature_params
    params.require(:feature).permit(:title, :description, :tag_list)
  end

  def execution_params
    return {} unless params[:executions].is_a?(ActionController::Parameters) || params[:executions].is_a?(Hash)

    permitted = {}
    params[:executions].each do |scenario_id, execution_data|
      next unless scenario_id.present?

      if execution_data.is_a?(ActionController::Parameters) || execution_data.is_a?(Hash)
        permitted[scenario_id] = {
          status: execution_data[:status],
          notes: execution_data[:notes]
        }
      end
    end
    permitted
  end

  def valid_tag_name?(tag_name)
    return false if tag_name.blank?
    return false if tag_name.length > 50
    # Reject tags with control characters or only whitespace
    tag_name.match?(/\A[^\x00-\x1F\x7F]+\z/) && tag_name.present?
  end
end
