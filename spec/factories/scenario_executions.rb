FactoryBot.define do
  factory :scenario_execution do
    association :scenario
    association :user
    status { "pending" }
    notes { nil }
    executed_at { Time.current }
  end
end
