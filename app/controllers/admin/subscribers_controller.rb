class Admin::SubscribersController < InheritedResources::Base
  before_filter :authenticate
  layout "admin"
  has_scope :page, :default => 1

end
