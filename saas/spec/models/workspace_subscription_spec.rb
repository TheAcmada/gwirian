# frozen_string_literal: true

require_relative "../../../spec/rails_helper"

RSpec.describe WorkspaceSubscription, type: :model do
  describe "#prepare_inline_checkout!" do
    let(:workspace) { create(:workspace) }
    let(:subscription) { WorkspaceSubscription.for_workspace(workspace) }
    let(:plan) { double("Plan", paid?: true, paddle_price_id: "pri_test_123") }

    context "when Paddle transaction is created successfully" do
      let(:paddle_transaction) { double("Paddle::Transaction", id: "txn_test_abc") }

      before do
        allow(::Paddle::Transaction).to receive(:create).and_return(paddle_transaction)
      end

      it "creates a transaction with custom_data including workspace_id" do
        subscription.prepare_inline_checkout!(plan: plan)

        expect(::Paddle::Transaction).to have_received(:create).with(
          hash_including(
            items: [ { price_id: "pri_test_123", quantity: 1 } ],
            custom_data: { workspace_id: workspace.id }
          )
        )
      end

      it "returns a hash with transaction_id" do
        result = subscription.prepare_inline_checkout!(plan: plan)

        expect(result).to eq({ transaction_id: "txn_test_abc" })
      end

      it "persists paddle_transaction_id and paddle_plan_price_id on the subscription" do
        subscription.prepare_inline_checkout!(plan: plan)

        subscription.reload
        expect(subscription.paddle_transaction_id).to eq("txn_test_abc")
        expect(subscription.paddle_plan_price_id).to eq("pri_test_123")
      end
    end

    context "when plan is free" do
      before { allow(plan).to receive(:paid?).and_return(false) }

      it "raises ArgumentError" do
        expect {
          subscription.prepare_inline_checkout!(plan: plan)
        }.to raise_error(ArgumentError, "Plan must be paid")
      end
    end

    context "when plan has no Paddle price ID" do
      before { allow(plan).to receive(:paddle_price_id).and_return(nil) }

      it "raises ArgumentError" do
        expect {
          subscription.prepare_inline_checkout!(plan: plan)
        }.to raise_error(ArgumentError, "Plan is missing Paddle price ID")
      end
    end
  end

  describe "scheduled change parsing" do
    it "maps scheduled_change from Paddle payload into scheduled_change_action and scheduled_change_effective_at" do
      data = {
        "id" => "sub_01",
        "customer_id" => "ctm_01",
        "status" => "active",
        "current_billing_period" => {
          "starts_at" => "2026-03-01T00:00:00Z",
          "ends_at" => "2026-04-07T00:00:00Z"
        },
        "items" => [ { "price_id" => "pri_starter" } ],
        "scheduled_change" => {
          "action" => "cancel",
          "effective_at" => "2026-04-07T00:00:00Z"
        }
      }
      allow(Plan).to receive(:find_by_paddle_price_id).with("pri_starter").and_return(double("Plan", key: "starter"))

      attrs = WorkspaceSubscription.attributes_from_paddle_data(data, current_plan_key: "starter")

      expect(attrs[:scheduled_change_action]).to eq("cancel")
      expect(attrs[:scheduled_change_effective_at]).to eq(Time.zone.parse("2026-04-07T00:00:00Z"))
    end

    it "sets scheduled_change fields to nil when payload has no scheduled_change" do
      data = {
        "id" => "sub_01",
        "customer_id" => "ctm_01",
        "status" => "active",
        "current_billing_period" => { "starts_at" => "2026-03-01T00:00:00Z", "ends_at" => "2026-04-07T00:00:00Z" },
        "items" => [ { "price_id" => "pri_starter" } ]
      }
      data["scheduled_change"] = nil
      allow(Plan).to receive(:find_by_paddle_price_id).and_return(double("Plan", key: "starter"))

      attrs = WorkspaceSubscription.attributes_from_paddle_data(data, current_plan_key: "starter")

      expect(attrs[:scheduled_change_action]).to be_nil
      expect(attrs[:scheduled_change_effective_at]).to be_nil
    end
  end

  describe "#pending_scheduled_change?" do
    let(:workspace) { create(:workspace) }
    let(:subscription) do
      create(:workspace_subscription, workspace: workspace, plan_key: "starter", status: "active",
        paddle_subscription_id: "sub_01", scheduled_change_action: "cancel",
        scheduled_change_effective_at: 1.month.from_now)
    end

    it "returns true when scheduled_change_action and future effective_at are set" do
      expect(subscription.pending_scheduled_change?).to be true
    end

    it "returns false when effective_at is in the past" do
      subscription.update!(scheduled_change_effective_at: 1.day.ago)
      expect(subscription.reload.pending_scheduled_change?).to be false
    end

    it "returns false when scheduled_change_action is blank" do
      subscription.update!(scheduled_change_action: nil)
      expect(subscription.reload.pending_scheduled_change?).to be false
    end
  end

  describe "#can_undo_scheduled_change?" do
    let(:workspace) { create(:workspace) }

    it "returns true when pending_scheduled_change? is true" do
      sub = create(:workspace_subscription, workspace: workspace, plan_key: "starter", status: "active",
        paddle_subscription_id: "sub_01", scheduled_change_action: "cancel",
        scheduled_change_effective_at: 1.month.from_now)
      expect(sub.can_undo_scheduled_change?).to be true
    end

    it "returns true when canceled? and on_grace_period?" do
      sub = create(:workspace_subscription, workspace: workspace, plan_key: "starter", status: "active",
        paddle_subscription_id: "sub_01", canceled_at: 1.day.ago,
        current_period_ends_at: 1.month.from_now)
      expect(sub.can_undo_scheduled_change?).to be true
    end

    it "returns false when active with no scheduled change" do
      sub = create(:workspace_subscription, workspace: workspace, plan_key: "starter", status: "active",
        paddle_subscription_id: "sub_01")
      expect(sub.can_undo_scheduled_change?).to be false
    end
  end

  describe "#keep_plan!" do
    let(:workspace) { create(:workspace) }
    let(:subscription) do
      create(:workspace_subscription, workspace: workspace, plan_key: "starter", status: "active",
        paddle_subscription_id: "sub_01", scheduled_change_action: "cancel",
        scheduled_change_effective_at: 1.month.from_now)
    end

    before do
      allow(::Paddle::Subscription).to receive(:update).with(id: "sub_01", scheduled_change: nil).and_return(true)
      paddle_response = {
        "data" => {
          "id" => "sub_01",
          "customer_id" => "ctm_01",
          "status" => "active",
          "current_billing_period" => { "starts_at" => "2026-03-01T00:00:00Z", "ends_at" => "2026-04-07T00:00:00Z" },
          "items" => [ { "price_id" => "pri_starter" } ]
        }
      }
      allow(::Paddle::Subscription).to receive(:retrieve).with(id: "sub_01").and_return(paddle_response)
    end

    it "calls Paddle to clear scheduled_change and syncs" do
      subscription.keep_plan!

      expect(::Paddle::Subscription).to have_received(:update).with(id: "sub_01", scheduled_change: nil)
      expect(::Paddle::Subscription).to have_received(:retrieve).with(id: "sub_01")
    end

    it "raises when subscription is not scheduled to cancel" do
      subscription.update!(scheduled_change_action: nil, scheduled_change_effective_at: nil)

      expect {
        subscription.reload.keep_plan!
      }.to raise_error(ArgumentError, "Subscription is not scheduled to cancel")
    end
  end

  describe "#reconcile_after_checkout!" do
    let(:workspace) { create(:workspace) }

    context "when paddle_subscription_id is present" do
      let(:subscription) do
        create(:workspace_subscription, workspace: workspace, plan_key: "starter", status: "active",
          paddle_subscription_id: "sub_01", paddle_transaction_id: "txn_01")
      end

      before do
        paddle_response = {
          "data" => {
            "id" => "sub_01",
            "customer_id" => "ctm_01",
            "status" => "active",
            "current_billing_period" => { "starts_at" => "2026-03-01T00:00:00Z", "ends_at" => "2026-04-07T00:00:00Z" },
            "items" => [ { "price_id" => "pri_starter" } ]
          }
        }
        allow(::Paddle::Subscription).to receive(:retrieve).with(id: "sub_01").and_return(paddle_response)
      end

      it "calls sync_with_paddle! and returns true" do
        result = subscription.reconcile_after_checkout!

        expect(result).to be true
        expect(::Paddle::Subscription).to have_received(:retrieve).with(id: "sub_01")
      end
    end

    context "when only paddle_transaction_id is present and transaction has subscription_id" do
      let(:subscription) do
        create(:workspace_subscription, workspace: workspace, plan_key: "free", status: "active",
          paddle_transaction_id: "txn_01", paddle_subscription_id: nil)
      end

      let(:paddle_transaction) { double("Paddle::Transaction", subscription_id: "sub_new", id: "txn_01") }
      let(:paddle_sub_response) do
        {
          "data" => {
            "id" => "sub_new",
            "customer_id" => "ctm_01",
            "status" => "active",
            "current_billing_period" => { "starts_at" => "2026-03-01T00:00:00Z", "ends_at" => "2026-04-07T00:00:00Z" },
            "items" => [ { "price_id" => "pri_starter" } ]
          }
        }
      end

      before do
        allow(::Paddle::Transaction).to receive(:retrieve).with(id: "txn_01").and_return(paddle_transaction)
        allow(::Paddle::Subscription).to receive(:retrieve).with(id: "sub_new").and_return(paddle_sub_response)
        allow(Plan).to receive(:find_by_paddle_price_id).with("pri_starter").and_return(double("Plan", key: "starter"))
      end

      it "retrieves transaction, sets paddle_subscription_id, syncs and returns true" do
        result = subscription.reconcile_after_checkout!

        expect(result).to be true
        expect(::Paddle::Transaction).to have_received(:retrieve).with(id: "txn_01")
        expect(::Paddle::Subscription).to have_received(:retrieve).with(id: "sub_new")
        subscription.reload
        expect(subscription.paddle_subscription_id).to eq("sub_new")
        expect(subscription.plan_key).to eq("starter")
      end
    end

    context "when only paddle_transaction_id is present and transaction has no subscription_id yet" do
      let(:subscription) do
        create(:workspace_subscription, workspace: workspace, plan_key: "free", status: "active",
          paddle_transaction_id: "txn_01", paddle_subscription_id: nil)
      end

      let(:paddle_transaction) { double("Paddle::Transaction", subscription_id: nil, id: "txn_01") }

      before do
        allow(::Paddle::Transaction).to receive(:retrieve).with(id: "txn_01").and_return(paddle_transaction)
        allow(::Paddle::Subscription).to receive(:retrieve)
      end

      it "returns false and does not call Subscription.retrieve" do
        result = subscription.reconcile_after_checkout!

        expect(result).to be false
        expect(::Paddle::Subscription).not_to have_received(:retrieve)
        subscription.reload
        expect(subscription.paddle_subscription_id).to be_nil
      end
    end

    context "when neither paddle_subscription_id nor paddle_transaction_id is present" do
      let(:subscription) do
        create(:workspace_subscription, workspace: workspace, plan_key: "free", status: "active",
          paddle_transaction_id: nil, paddle_subscription_id: nil)
      end

      it "returns false" do
        result = subscription.reconcile_after_checkout!

        expect(result).to be false
      end
    end
  end
end
