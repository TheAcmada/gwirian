FactoryBot.define do
  factory :project do
    sequence(:name) { |n| "Project #{n}" }
    description { "A test project description" }
    context { nil }
    workspace

    trait :with_context do
      context { "environments:\n  local: http://localhost:3000\n  staging: https://staging.example.com\naccounts:\n  - email: test@example.com\n    role: viewer\n" }
    end
  end
end
