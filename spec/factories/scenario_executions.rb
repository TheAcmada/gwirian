FactoryBot.define do
  factory :scenario_execution do
    association :scenario
    association :user
    status { "pending" }
    notes { nil }
    executed_at { Time.current }

    trait :with_tags do
      after(:build) { |e| e.tag_list = "e2e, smoke" }
    end
  end
end
