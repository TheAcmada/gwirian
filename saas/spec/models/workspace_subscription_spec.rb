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
end
