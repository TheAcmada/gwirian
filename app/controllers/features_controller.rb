class FeaturesController < ApplicationController
  before_action :set_project
  before_action :set_feature, only: [ :show, :update, :destroy, :add_tag, :remove_tag, :start_execution, :select_scenarios, :execute_scenarios ]

  def index
    @features = @project.features.order(:title)
  end

  def show
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
      if request.headers["HX-Request"]
        render partial: "features/feature_header", locals: { feature: @feature, project: @project }
      else
        redirect_to project_feature_path(@project, @feature), notice: "Feature updated successfully"
      end
    else
      if request.headers["HX-Request"]
        render partial: "features/feature_header", locals: { feature: @feature, project: @project }, status: :unprocessable_entity
      else
        render :show, status: :unprocessable_entity
      end
    end
  end

  def destroy
    authorize! :destroy, @feature

    @feature.destroy

    if request.headers["HX-Request"]
      @features = @project.features.order(:title)
      render partial: "features/features", locals: { features: @features, project: @project, notice: "Feature deleted successfully" }
    else
      redirect_to project_features_path(@project), notice: "Feature deleted successfully"
    end
  end

  def add_tag
    authorize! :update, @feature

    tag_name = params[:tag_name]&.strip
    if tag_name.present?
      @feature.tag_list.add(tag_name)
      @feature.save
    end

    if request.headers["HX-Request"]
      render partial: "features/feature_header", locals: { feature: @feature.reload, project: @project }
    else
      redirect_to project_feature_path(@project, @feature)
    end
  end

  def remove_tag
    authorize! :update, @feature

    tag_name = params[:tag_name]&.strip
    if tag_name.present?
      @feature.tag_list.remove(tag_name)
      @feature.save
    end

    if request.headers["HX-Request"]
      render partial: "features/feature_header", locals: { feature: @feature.reload, project: @project }
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
      @scenarios = @feature.scenarios.order(:position)
    elsif request.post?
      selected_ids = params[:scenario_ids] || []
      session[:selected_scenario_ids] = selected_ids.map(&:to_i)
      redirect_to execute_scenarios_project_feature_path(@project, @feature)
    end
  end

  def execute_scenarios
    authorize! :execute, @feature

    if request.get?
      selected_ids = session[:selected_scenario_ids] || []
      @scenarios = @feature.scenarios.where(id: selected_ids).order(:position)
      @scenarios = @scenarios.to_a.sort_by { |s| selected_ids.index(s.id) }
    elsif request.post?
      executions_data = params[:executions] || {}
      executed_count = 0

      executions_data.each do |scenario_id, execution_params|
        scenario = @feature.scenarios.find_by(id: scenario_id)
        next unless scenario

        status = execution_params[:status]
        notes = execution_params[:notes]
        next unless status.present? && %w[passed failed].include?(status)

        ScenarioExecution.create!(
          scenario: scenario,
          user: Current.user,
          status: status,
          notes: notes,
          executed_at: Time.current
        )
        executed_count += 1
      end

      session.delete(:selected_scenario_ids)
      redirect_to project_feature_path(@project, @feature), notice: "#{executed_count} scenario(s) executed successfully"
    end
  end

  private

  def set_project
    @project = Current.user.projects.find(params[:project_id])
  end

  def set_feature
    @feature = @project.features.find(params[:id])
  end

  def feature_params
    params.require(:feature).permit(:title, :description, :tag_list)
  end
end
