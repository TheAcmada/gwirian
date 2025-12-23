FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { "password123456" } # 12+ characters to meet validation

    trait :with_api_token do
      after(:create) do |user|
        user.generate_api_token
      end
    end

    trait :with_expired_api_token do
      after(:create) do |user|
        user.api_token = SecureRandom.urlsafe_base64(32)
        user.api_token_expires_at = 1.day.ago
        user.save!
      end
    end
  end
end
