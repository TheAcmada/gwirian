class TestCaseCardComponent < ApplicationComponent
  def initialize(test_case:, project:, deletable: false)
    @test_case = test_case
    @project = project
    @deletable = deletable
  end

  private

  attr_reader :test_case, :project, :deletable

  def status_badge_class
    case test_case.status
    when "active" then "badge-success"
    when "deprecated" then "badge-warning"
    else "badge-neutral"
    end
  end

  def priority_badge_class
    case test_case.priority
    when "critical" then "badge-error"
    when "high" then "badge-warning"
    when "medium" then "badge-info"
    else "badge-neutral"
    end
  end
end
