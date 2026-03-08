# frozen_string_literal: true

FactoryBot.define do
  factory :workspace_subscription, class: "WorkspaceSubscription" do
    association :workspace
    plan_key { "free" }
    status { "active" }
  end
end
