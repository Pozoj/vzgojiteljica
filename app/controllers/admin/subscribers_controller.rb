class Admin::SubscribersController < Admin::AdminController
  has_scope :page, :default => 1

  def show
    respond_with resource
  end

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

    respond_with resource
  end

  private

  def resource
    @subscriber ||= Subscriber.find(params[:id])
  end
end
