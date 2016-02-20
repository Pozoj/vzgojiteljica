class Admin::SubscriptionsController < Admin::AdminController
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
    resource.remarks.create user: current_user, remark: "Naročnina preklicana"
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
    resource.remarks.create user: current_user, remark: "Naročnina ponovno aktivirana"
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
