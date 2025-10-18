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

  def priority_border_class
    case test_case.priority
    when "critical" then "bg-gradient-to-b from-red-500/60 to-red-300/60"
    when "high" then "bg-gradient-to-b from-orange-400/60 to-amber-300/60"
    when "medium" then "bg-gradient-to-b from-lime-400/60 to-yellow-300/60"
    else "bg-gradient-to-b from-green-500/60 to-green-300/60"
    end
  end
end
