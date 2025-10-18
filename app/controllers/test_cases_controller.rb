class TestCasesController < ApplicationController
  before_action :set_project
  before_action :set_test_case, only: [ :edit, :update, :destroy ]

  def index
    @test_cases = @project.test_cases.includes(:test_steps)
    unless can? :read, @project
      render_alert("You are not authorized to view test cases for this project")
    end
  end


  def new
    @test_case = @project.test_cases.build
    unless can? :create, @test_case
      render_alert("You are not authorized to create test cases for this project")
    end
  end

  def create
    @test_case = @project.test_cases.build(test_case_params)
    unless can? :create, @test_case
      render_alert("You are not authorized to create test cases for this project")
      return
    end

    if @test_case.save
      redirect_to edit_project_test_case_path(@project, @test_case), notice: "Test case has been created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    unless can? :update, @test_case
      render_alert("You are not authorized to edit this test case")
    end
  end

  def update
    unless can? :update, @test_case
      render_alert("You are not authorized to update this test case")
      return
    end

    if @test_case.update(test_case_params)
      redirect_to project_test_cases_path(@project), notice: "Test case has been updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    unless can? :destroy, @test_case
      render_alert("You are not authorized to delete this test case")
      return
    end

    @test_case.destroy
    if request.headers["HX-Request"]
      head :ok
    else
      redirect_to project_test_cases_path(@project), notice: "Test case has been deleted successfully"
    end
  end

  private

  def set_project
    @project = Current.user.projects.find(params[:project_id])
  end

  def set_test_case
    @test_case = @project.test_cases.find(params[:id])
  end

  def test_case_params
    params.require(:test_case).permit(
      :title, :description, :preconditions, :expected_result,
      :priority, :status, :category, :tag_list,
      test_steps_attributes: [ :id, :position, :action, :expected_result, :_destroy ]
    )
  end

  def render_alert(message)
    redirect_to project_test_cases_path(@project), alert: message
  end
end
