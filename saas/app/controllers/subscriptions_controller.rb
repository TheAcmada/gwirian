# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :require_workspace
  before_action :require_admin
  before_action :load_workspace_context

  def show
    if params[:checkout] == "success"
      @subscription.reconcile_after_checkout!
    else
      @subscription.sync_with_paddle!
    end
    @plan = @subscription.plan
    @plans = Plan.all
    @checkout_return = params[:checkout] == "success"
    @upgrade_pending = @checkout_return && !@subscription.paid?
  end

  def new
    plan_key = params[:plan_key]
    plan = Plan.find(plan_key)

    unless plan&.paid? && plan.paddle_price_id.present?
      redirect_to subscription_path, alert: "Invalid plan selected"
      return
    end

    if @subscription.paid? && @subscription.active? && !@subscription.canceled?
      redirect_to subscription_path, alert: "You already have an active subscription. Use the plan cards to switch plans."
      return
    end

    @checkout = @subscription.prepare_inline_checkout!(plan: plan).merge(
      success_url: subscription_url(checkout: "success")
    )
    @plan = plan
  rescue ArgumentError => e
    redirect_to subscription_path, alert: e.message
  rescue ::Paddle::Errors::BadRequestError => e
    redirect_to subscription_path, alert: "Unable to start checkout: #{e.message}"
  end

  def cancel
    @subscription.cancel_at_period_end!
    redirect_to subscription_path, notice: "Your subscription will be canceled at the end of the current billing period."
  rescue ArgumentError => e
    redirect_to subscription_path, alert: e.message
  rescue ::Paddle::Errors::BadRequestError => e
    redirect_to subscription_path, alert: "Unable to cancel subscription: #{e.message}"
  end

  def resume
    @subscription.resume_immediately!
    redirect_to subscription_path, notice: "Your subscription has been resumed."
  rescue ArgumentError => e
    redirect_to subscription_path, alert: e.message
  rescue ::Paddle::Errors::BadRequestError => e
    redirect_to subscription_path, alert: "Unable to resume subscription: #{e.message}"
  end

  def keep_plan
    @subscription.keep_plan!
    redirect_to subscription_path, notice: "Your subscription will continue. The scheduled cancellation has been removed."
  rescue ArgumentError => e
    redirect_to subscription_path, alert: e.message
  rescue ::Paddle::Errors::BadRequestError => e
    redirect_to subscription_path, alert: "Unable to keep subscription: #{e.message}"
  end

  def update_plan
    plan_key = params[:plan_key]
    plan = Plan.find(plan_key)

    unless plan&.paid? && plan.paddle_price_id.present?
      redirect_to subscription_path, alert: "Invalid plan selected"
      return
    end

    if plan.key == @subscription.plan.key
      redirect_to subscription_path, notice: "You are already on #{plan.name}."
      return
    end

    @subscription.change_plan_to!(plan: plan)
    redirect_to subscription_path, notice: "Your subscription has been updated to #{plan.name}."
  rescue ArgumentError => e
    redirect_to subscription_path, alert: e.message
  rescue ::Paddle::Errors::BadRequestError => e
    redirect_to subscription_path, alert: "Unable to update subscription: #{e.message}"
  end

  def status
    @subscription.reconcile_after_checkout!
    render json: {
      paid: @subscription.paid?,
      plan_key: @subscription.plan_key
    }
  end

  def portal
    unless @subscription.paddle_customer_id.present?
      redirect_to subscription_path, alert: "No billing information available"
      return
    end

    begin
      portal_session = ::Paddle::PortalSession.create(
        customer: @subscription.paddle_customer_id,
        subscription_ids: [ @subscription.paddle_subscription_id ].compact
      )
      redirect_to portal_session.urls.general.overview, allow_other_host: true
    rescue ::Paddle::Errors::BadRequestError => e
      redirect_to subscription_path, alert: "Unable to open billing portal: #{e.message}"
    end
  end

  private

  def require_admin
    unless Current.workspace.admin?(Current.user)
      redirect_to projects_path, alert: "Only workspace administrators can manage subscriptions."
    end
  end

  def load_workspace_context
    @workspace = Current.workspace
    @subscription = WorkspaceSubscription.for_workspace(@workspace)
    @plan = @workspace.plan
  end
end
