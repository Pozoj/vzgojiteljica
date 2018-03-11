# frozen_string_literal: true

class Admin::SubscriptionsController < Admin::AdminController
  def index
    @subscriptions = Subscription.all
    if params[:active]
      @subscriptions = @subscriptions.active
    elsif params[:inactive]
      @subscriptions = @subscriptions.inactive
    elsif params[:yearly]
      @subscriptions = @subscriptions.active.yearly
    elsif params[:per_issue]
      @subscriptions = @subscriptions.active.per_issue
    elsif params[:free]
      @subscriptions = @subscriptions.free
    elsif params[:without_order_form]
      @subscriptions = @subscriptions.active.without_order_form
    elsif params[:rewards]
      @subscriptions = @subscriptions.active.rewards
    elsif params[:ending_last_year]
      @subscriptions = @subscriptions.where(Subscription.arel_table[:end].not_eq(nil).and(Subscription.arel_table[:end].lt(Date.today.beginning_of_year)).and(Subscription.arel_table[:end].gteq(1.year.ago.beginning_of_year)))
    end

    @subscriptions = @subscriptions.order(end: :desc, quantity: :desc, id: :desc).page(params[:page])
  end

  def patricija
    @subscriptions = Subscription
                     .paid
                     .inactive
                     .order(end: :desc, quantity: :desc, id: :desc)
                     .reject do |subscription|
                       subscription.customer.active?
                     end
  end

  def show
    respond_with resource
  end

  def new
    subscriber_id = params.delete(:subscriber_id)
    if subscriber_id && @subscriber = Subscriber.find(subscriber_id)
      @subscription = @subscriber.subscriptions.build

      if params[:yearly]
        @subscription.start = 1.year.from_now.beginning_of_year
        @subscription.plan = Plan.latest_yearly
      end
    end

    respond_with resource
  end

  def create
    @subscription = Subscription.create resource_params
    respond_with resource, location: -> { admin_subscription_path(@subscription) }
  end

  def edit
    respond_with resource, location: -> { admin_subscription_path(@subscription) }
  end

  def update
    resource.update_attributes resource_params
    respond_with resource, location: -> { admin_subscription_path(@subscription) }
  end

  def new_from_order
    order = Order.find(params[:order_id])
    subscriber = Subscriber.find(params[:subscriber_id])
    begin
      subscription = Subscription.new_from_order(subscriber: subscriber, order: order)
      order.order_form.processed!(user_id: current_user.id)
      redirect_to admin_subscription_path(subscription), notice: "Naročnina uspešno ustvarjena iz naročila ##{order.id}"
    rescue Subscription::FromOrderError => e
      redirect_to admin_order_path(order), error: "Napaka pri ustvarjanju naročnine iz naročila #{e.inspect}"
    end
  end

  def end_now
    resource.end = DateTime.now
    resource.save
    resource.remarks.create user: current_user, remark: 'Naročnina preklicana'
    redirect_to admin_subscription_path(resource)
  end

  def end_by_end_of_year
    resource.end = DateTime.now.end_of_year
    resource.save
    resource.remarks.create user: current_user, remark: "Naročnina se bo končala konec leta #{DateTime.now.year}"
    redirect_to admin_subscription_path(resource)
  end

  def reinstate
    resource.end = nil
    resource.save
    resource.remarks.create user: current_user, remark: 'Naročnina ponovno aktivirana'
    redirect_to admin_subscription_path(resource)
  end

  private

  def resource
    return unless params[:id]
    @subscription ||= Subscription.find(params[:id])
  end

  def resource_params
    params.require(:subscription)
  end

  def set_page_title
    @page_title = 'Naročnine'
  end
end
