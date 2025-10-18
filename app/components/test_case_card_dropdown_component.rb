class TestCaseCardDropdownComponent < ApplicationComponent
  def initialize(test_case:, project:)
    @test_case = test_case
    @project = project
  end

  private

  attr_reader :test_case, :project
end
