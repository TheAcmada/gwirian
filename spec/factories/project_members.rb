FactoryBot.define do
  factory :project_member do
    association :project
    sequence(:email) { |n| "member#{n}@example.com" }
    role { "viewer" }
    invitation_accepted { true }

    trait :administrator do
      role { "administrator" }
    end

    trait :editor do
      role { "editor" }
    end

    trait :viewer do
      role { "viewer" }
    end

    trait :pending do
      invitation_accepted { false }
    end
  end
end
