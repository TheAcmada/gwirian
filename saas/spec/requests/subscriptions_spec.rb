# frozen_string_literal: true

require_relative "../../../spec/rails_helper"

RSpec.describe "Subscriptions", type: :request do
  before do
    allow(Gwirian).to receive(:saas?).and_return(true)
  end

  describe "GET /subscription/new" do
    let(:workspace) { create(:workspace) }
    let(:user) { create(:user) }
    let!(:workspace_member) { create(:workspace_member, user: user, workspace: workspace, role: "administrator", status: "current_member") }

    before do
      sign_in_as(user)
    end

    context "with valid paid plan_key" do
      let(:starter_plan) { double("Plan", key: "starter", name: "Starter", paid?: true, paddle_price_id: "pri_test") }
      let(:free_plan) { double("Plan", key: "free", name: "Free", paid?: false, paddle_price_id: nil) }

      before do
        allow(Plan).to receive(:find).and_call_original
        allow(Plan).to receive(:find).with("starter").and_return(starter_plan)
        allow(Plan).to receive(:find).with("free").and_return(free_plan)
        paddle_transaction = double("Paddle::Transaction", id: "txn_test_123")
        allow(::Paddle::Transaction).to receive(:create).and_return(paddle_transaction)
      end

      it "returns success and renders the checkout page" do
        get "/#{workspace.slug}/subscription/new", params: { plan_key: "starter" }

        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:new)
      end

      it "assigns checkout data with transaction_id and success_url" do
        get "/#{workspace.slug}/subscription/new", params: { plan_key: "starter" }

        expect(assigns(:checkout)).to be_a(Hash)
        expect(assigns(:checkout)[:transaction_id]).to eq("txn_test_123")
        expect(assigns(:checkout)[:success_url]).to be_present
      end

      it "renders the inline checkout container and data attributes" do
        get "/#{workspace.slug}/subscription/new", params: { plan_key: "starter" }

        expect(response.body).to include("checkout-container")
        expect(response.body).to include("data-checkout-transaction-id")
        expect(response.body).to include("txn_test_123")
      end
    end

    context "with invalid or missing plan_key" do
      it "redirects to subscription path with alert when plan_key is invalid" do
        get "/#{workspace.slug}/subscription/new", params: { plan_key: "nonexistent" }

        expect(response).to redirect_to(subscription_path)
        follow_redirect!
        expect(response.body).to include("Invalid plan selected")
      end

      it "redirects when plan has no Paddle price ID" do
        plan_without_price = double("Plan", key: "starter", name: "Starter", paid?: true, paddle_price_id: nil)
        allow(Plan).to receive(:find).and_call_original
        allow(Plan).to receive(:find).with("starter").and_return(plan_without_price)
        allow(Plan).to receive(:find).with("free").and_return(double("Plan", key: "free", paid?: false, paddle_price_id: nil))
        get "/#{workspace.slug}/subscription/new", params: { plan_key: "starter" }

        expect(response).to redirect_to(subscription_path)
      end
    end

    context "when user already has an active paid subscription" do
      before do
        create(:workspace_subscription, workspace: workspace, plan_key: "starter", status: "active", paddle_subscription_id: "sub_123")
      end

      it "redirects to subscription path with alert" do
        get "/#{workspace.slug}/subscription/new", params: { plan_key: "starter" }

        expect(response).to redirect_to(subscription_path)
      end
    end

    context "when not authenticated" do
      it "redirects to login or root" do
        get "/#{workspace.slug}/subscription/new", params: { plan_key: "starter" }

        expect(response).to have_http_status(:redirect)
        expect(response.redirect?).to be true
      end
    end

    context "when user is not workspace admin" do
      let!(:workspace_member) { create(:workspace_member, user: user, workspace: workspace, role: "viewer", status: "current_member") }

      it "redirects to projects with alert" do
        get "/#{workspace.slug}/subscription/new", params: { plan_key: "starter" }

        expect(response).to redirect_to(projects_path)
        follow_redirect!
        expect(response.body).to include("Only workspace administrators")
      end
    end
  end

  describe "GET /subscription (show)" do
    let(:workspace) { create(:workspace) }
    let(:user) { create(:user) }
    let!(:workspace_member) { create(:workspace_member, user: user, workspace: workspace, role: "administrator", status: "current_member") }

    before { sign_in_as(user) }

    context "when subscription has pending scheduled cancellation" do
      before do
        create(:workspace_subscription, workspace: workspace, plan_key: "starter", status: "active",
          paddle_subscription_id: "sub_01", paddle_customer_id: "ctm_01",
          scheduled_change_action: "cancel", scheduled_change_effective_at: 1.month.from_now,
          current_period_ends_at: 1.month.from_now)
        allow_any_instance_of(WorkspaceSubscription).to receive(:sync_with_paddle!).and_return(true)
      end

      it "renders pending downgrade message and Keep this plan button" do
        get "/#{workspace.slug}/subscription"

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Downgrade to Free scheduled for")
        expect(response.body).to include("Keep this plan")
      end

      it "does not show Downgrade to Free button on Free plan card when cancellation is already scheduled" do
        get "/#{workspace.slug}/subscription"

        # "Downgrade to Free" appears only in the status line ("Downgrade to Free scheduled for..."), not as a button
        expect(response.body.scan("Downgrade to Free").size).to eq(1)
      end
    end

    context "POST keep_plan when subscription has pending scheduled change" do
      let(:subscription) do
        create(:workspace_subscription, workspace: workspace, plan_key: "starter", status: "active",
          paddle_subscription_id: "sub_01", scheduled_change_action: "cancel",
          scheduled_change_effective_at: 1.month.from_now)
      end

      before do
        subscription
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

      it "removes scheduled cancellation and redirects with notice" do
        post "/#{workspace.slug}/subscription/keep_plan"

        expect(response).to redirect_to(subscription_path)
        follow_redirect!
        expect(response.body).to include("scheduled cancellation has been removed")
      end
    end
  end
end
