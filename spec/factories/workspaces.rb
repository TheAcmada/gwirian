FactoryBot.define do
  factory :workspace do
    sequence(:name) { |n| "Workspace #{n}" }
    sequence(:slug) { |n| "workspace-#{n}" }
    description { "A test workspace description" }
  end
end
