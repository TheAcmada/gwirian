# frozen_string_literal: true

require "rails_helper"

RSpec.describe Feature, type: :model do
  let(:project) { create(:project, workspace: create(:workspace)) }

  describe "#to_gherkin" do
    it "returns Feature line with title" do
      feature = create(:feature, project: project, title: "User authentication")
      expect(feature.to_gherkin).to include("Feature: User authentication")
    end

    it "includes description when present" do
      feature = create(:feature, project: project, title: "Auth", description: "As a user I want to log in")
      expect(feature.to_gherkin).to include("As a user I want to log in")
    end

    it "includes tags line when feature has tags" do
      feature = create(:feature, :with_tags, project: project, title: "Auth")
      gherkin = feature.to_gherkin
      expect(gherkin).to match(/@tag1 @tag2 @tag3/)
      expect(gherkin).to include("Feature: Auth")
    end

    it "includes Background when present" do
      feature = create(:feature, project: project, title: "Auth", background: "User is on the site")
      expect(feature.to_gherkin).to include("Background:")
      expect(feature.to_gherkin).to include("Given User is on the site")
    end

    it "includes scenario blocks" do
      feature = create(:feature, project: project, title: "Cart")
      scenario = create(:scenario, feature: feature, title: "Add item")
      scenario.update_columns(given: "cart is empty", when: "user adds item", then: "cart has one item")
      scenario.reload
      gherkin = feature.to_gherkin
      expect(gherkin).to include("Feature: Cart")
      expect(gherkin).to include("Scenario: Add item")
      expect(gherkin).to include("Given cart is empty")
      expect(gherkin).to include("When user adds item")
      expect(gherkin).to include("Then cart has one item")
    end
  end
end
