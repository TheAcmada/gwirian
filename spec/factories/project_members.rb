FactoryBot.define do
  factory :project_member do
    association :project
    sequence(:email) { |n| "member#{n}@example.com" }
    role { "viewer" }

    trait :administrator do
      role { "administrator" }
    end

    trait :editor do
      role { "editor" }
    end

    trait :viewer do
      role { "viewer" }
    end
  end
end
