class Admin::SubscribersController < InheritedResources::Base
  before_filter :authenticate
  layout "admin"
  has_scope :page, :default => 1

  def new
    customer_id = params.delete(:customer_id)
    if customer_id && @customer = Customer.find(customer_id)
      @subscriber = @customer.subscribers.build

      if params[:customer]
        @subscriber.name = @customer.name
        @subscriber.title = @customer.title
        @subscriber.address = @customer.address
        @subscriber.post_id = @customer.post_id
      end
    end

    new!
  end
end
