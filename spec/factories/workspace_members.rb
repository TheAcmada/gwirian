FactoryBot.define do
  factory :workspace_member do
    association :workspace
    association :user
    role { "viewer" }
    status { "current_member" }

    trait :with_api_token do
      after(:create) do |workspace_member|
        workspace_member.generate_api_token
      end
    end

    trait :with_expired_api_token do
      after(:create) do |workspace_member|
        workspace_member.api_token = SecureRandom.urlsafe_base64(32)
        workspace_member.api_token_expires_at = 1.day.ago
        workspace_member.save!
      end
    end
  end
end
