class Admin::SubscribersController < InheritedResources::Base
  before_filter :authenticate
  layout "admin"
  has_scope :page, :default => 1

  def new
    customer_id = params.delete(:customer_id)
    if customer_id && @customer = Customer.find(customer_id)
      @subscriber = @customer.subscribers.build
    end

    new!
  end
end
