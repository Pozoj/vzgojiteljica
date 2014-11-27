class Admin::SubscriptionsController < InheritedResources::Base
  before_filter :authenticate
  layout "admin"

  def new
    subscriber_id = params.delete(:subscriber_id)
    if subscriber_id && @subscriber = Subscriber.find(subscriber_id)
      @subscription = @subscriber.subscriptions.build

      if params[:yearly]
        @subscription.start = 1.year.from_now.beginning_of_year
        @subscription.plan = Plan.latest_yearly
      end
    end

    new!
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
end
