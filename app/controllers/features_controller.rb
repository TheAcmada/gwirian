class FeaturesController < ApplicationController
  before_action :set_project

  def index
    @features = @project.features.order(:title)
  end

  def show
    @feature = @project.features.find(params[:id])
  end


  private

  def set_project
    @project = Current.user.projects.find(params[:project_id])
  end
end
