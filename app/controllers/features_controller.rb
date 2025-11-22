class FeaturesController < ApplicationController
  before_action :set_project
  before_action :set_feature, only: [ :show, :update, :destroy, :add_tag, :remove_tag ]

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
