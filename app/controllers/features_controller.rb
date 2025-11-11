class FeaturesController < ApplicationController
  before_action :set_project
  before_action :set_feature, only: [ :show, :update, :destroy ]

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

  private

  def set_project
    @project = Current.user.projects.find(params[:project_id])
  end

  def set_feature
    @feature = @project.features.find(params[:id])
  end

  def feature_params
    params.require(:feature).permit(:title, :description)
  end
end
