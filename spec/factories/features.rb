FactoryBot.define do
  factory :feature do
    association :project
    sequence(:title) { |n| "Feature #{n}" }
    description { "A test feature description" }

    trait :with_tags do
      after(:create) do |feature|
        feature.tag_list = "tag1, tag2, tag3"
        feature.save!
      end
    end
  end
end
