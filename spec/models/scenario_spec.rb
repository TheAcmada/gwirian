# frozen_string_literal: true

require "rails_helper"

RSpec.describe Scenario, type: :model do
  describe "#to_gherkin" do
    let(:feature) { create(:feature, project: create(:project, workspace: create(:workspace))) }

    it "returns Scenario line with title" do
      scenario = create(:scenario, feature: feature, title: "User logs in")
      expect(scenario.to_gherkin).to include("Scenario: User logs in")
    end

    it "includes Given when present" do
      scenario = create(:scenario, feature: feature, title: "Login", given: "the user is on the login page")
      expect(scenario.to_gherkin).to include("Given the user is on the login page")
    end

    it "includes When when present" do
      scenario = create(:scenario, feature: feature, title: "Login")
      scenario.update_columns(given: nil, when: "the user submits credentials", then: nil)
      scenario.reload
      expect(scenario.to_gherkin).to include("When the user submits credentials")
    end

    it "includes Then when present" do
      scenario = create(:scenario, feature: feature, title: "Login")
      scenario.update_columns(given: nil, when: nil, then: "the user sees the dashboard")
      scenario.reload
      expect(scenario.to_gherkin).to include("Then the user sees the dashboard")
    end

    it "includes all three steps when present" do
      scenario = create(:scenario, feature: feature, title: "Add to cart")
      scenario.update_columns(
        given: "the user is viewing a product",
        when: "the user clicks Add to Cart",
        then: "the cart shows one item"
      )
      scenario.reload
      gherkin = scenario.to_gherkin
      expect(gherkin).to include("Scenario: Add to cart")
      expect(gherkin).to include("Given the user is viewing a product")
      expect(gherkin).to include("When the user clicks Add to Cart")
      expect(gherkin).to include("Then the cart shows one item")
    end

    it "omits empty steps" do
      scenario = create(:scenario, feature: feature, title: "Minimal")
      scenario.update_columns(given: nil, when: nil, then: nil)
      scenario.reload
      expect(scenario.to_gherkin).to eq("Scenario: Minimal")
    end
  end
end
