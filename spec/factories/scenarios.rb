FactoryBot.define do
  factory :scenario do
    association :feature
    sequence(:title) { |n| "Scenario #{n}" }
    given { nil }
    position { nil }
    # Note: 'when' and 'then' are reserved keywords in Ruby, so they cannot be set directly in the factory.
    # Set them explicitly in tests if needed, e.g.: create(:scenario, when: "value", then: "value")
  end
end
