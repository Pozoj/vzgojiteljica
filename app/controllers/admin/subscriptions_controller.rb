class Admin::SubscriptionsController < InheritedResources::Base
  before_filter :authenticate
  layout "admin"

  def end_subscription
    resource.end = DateTime.now
    resource.save
    resource.remarks.create user: current_user, remark: "Naročnina preklicana"
    redirect_to admin_subscription_path(resource)
  end
end
