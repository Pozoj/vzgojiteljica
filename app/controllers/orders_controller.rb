class OrdersController < InheritedResources::Base
  before_filter :authenticate
  skip_before_filter :authenticate, only: [:new, :create]
end
