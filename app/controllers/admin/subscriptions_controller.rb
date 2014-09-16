class Admin::SubscriptionsController < InheritedResources::Base
  before_filter :authenticate
  layout "admin"
end
