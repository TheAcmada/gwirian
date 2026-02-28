# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :require_workspace
  before_action :require_admin

  def show
    sync_subscriptions
    @workspace = Current.workspace
    @subscription = @workspace.workspace_subscription
    @plan = @workspace.plan
    @plans = Plan.all
  end

  def create
    workspace = Current.workspace
    subscription = workspace.workspace_subscription || WorkspaceSubscription.new(workspace_id: workspace.id)

    plan_key = params[:plan_key]
    plan = Plan.find(plan_key)

    unless plan&.paid?
      redirect_to subscription_path, alert: "Invalid plan selected"
      return
    end

    render json: {
      paddle_price_id: plan.paddle_price_id,
      workspace_id: workspace.id,
      customer_email: Current.user.email_address,
      paddle_customer_id: subscription.paddle_customer_id
    }
  end

  def cancel
    workspace = Current.workspace
    subscription = workspace.workspace_subscription

    unless subscription&.paddle_subscription_id.present?
      redirect_to subscription_path, alert: "No active subscription to cancel"
      return
    end

    begin
      ::Paddle::Subscription.cancel(id: subscription.paddle_subscription_id, effective_from: "next_billing_period")
      redirect_to subscription_path, notice: "Your subscription will be canceled at the end of the current billing period."
    rescue ::Paddle::Errors::BadRequestError => e
      redirect_to subscription_path, alert: "Unable to cancel subscription: #{e.message}"
    end
  end

  def resume
    workspace = Current.workspace
    subscription = workspace.workspace_subscription

    unless subscription&.paddle_subscription_id.present? && subscription.paused?
      redirect_to subscription_path, alert: "No paused subscription to resume"
      return
    end

    begin
      ::Paddle::Subscription.resume(id: subscription.paddle_subscription_id, effective_from: "immediately")
      redirect_to subscription_path, notice: "Your subscription has been resumed."
    rescue ::Paddle::Errors::BadRequestError => e
      redirect_to subscription_path, alert: "Unable to resume subscription: #{e.message}"
    end
  end

  def update_plan
    workspace = Current.workspace
    subscription = workspace.workspace_subscription

    unless subscription&.paddle_subscription_id.present? && !subscription.canceled?
      redirect_to subscription_path, alert: "No active subscription to update"
      return
    end

    plan_key = params[:plan_key]
    plan = Plan.find(plan_key)

    unless plan&.paid? && plan.paddle_price_id.present?
      redirect_to subscription_path, alert: "Invalid plan selected"
      return
    end

    if plan.key == workspace.plan&.key
      redirect_to subscription_path, notice: "You are already on #{plan.name}."
      return
    end

    begin
      ::Paddle::Subscription.update(
        id: subscription.paddle_subscription_id,
        items: [ { price_id: plan.paddle_price_id, quantity: 1 } ],
        proration_billing_mode: "prorated_immediately"
      )
      redirect_to subscription_path, notice: "Your subscription has been updated to #{plan.name}. Changes may take a moment to appear."
    rescue ::Paddle::Errors::BadRequestError => e
      redirect_to subscription_path, alert: "Unable to update subscription: #{e.message}"
    end
  end

  def portal
    workspace = Current.workspace
    subscription = workspace.workspace_subscription

    unless subscription&.paddle_customer_id.present?
      redirect_to subscription_path, alert: "No billing information available"
      return
    end

    begin
      portal_session = ::Paddle::PortalSession.create(
        customer: subscription.paddle_customer_id,
        subscription_ids: [ subscription.paddle_subscription_id ].compact
      )
      redirect_to portal_session.urls.general.overview, allow_other_host: true
    rescue ::Paddle::Errors::BadRequestError => e
      redirect_to subscription_path, alert: "Unable to open billing portal: #{e.message}"
    end
  end

  private

  def sync_subscriptions
    workspace = Current.workspace
    subscription = workspace.workspace_subscription
    return false unless subscription&.paddle_subscription_id.present?

    paddle_data = ::Paddle::Subscription.retrieve(id: subscription.paddle_subscription_id)
    data = paddle_data.is_a?(Hash) ? paddle_data : paddle_data.to_h
    data = data["data"] if data.key?("data") && data["data"].present?
    attrs = ::Paddle::WebhookProcessorService.attributes_from_paddle_data(data, current_plan_key: subscription.plan_key)
    return false if attrs[:paddle_subscription_id].blank?

    subscription.assign_attributes(attrs)
    subscription.save!
    true
  rescue ::Paddle::Errors::BadRequestError, ::Paddle::Errors::ForbiddenError
    false
  end

  def require_admin
    unless Current.workspace.admin?(Current.user)
      redirect_to projects_path, alert: "Only workspace administrators can manage subscriptions."
    end
  end
end
