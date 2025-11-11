class FeaturesController < ApplicationController
  before_action :set_project

  def index
    @features = @project.features.order(:title)
  end

  def show
    @feature = @project.features.find(params[:id])
  end

  def update
    @feature = @project.features.find(params[:id])

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

  private

  def set_project
    @project = Current.user.projects.find(params[:project_id])
  end

  def feature_params
    params.require(:feature).permit(:title, :description)
  end
end
