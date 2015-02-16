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

  def create
    @subscriber = Subscriber.create resource_params
    respond_with resource, location: -> { admin_subscriber_path(@subscriber) }
  end

  def edit
    respond_with resource, location: -> { admin_subscriber_path(@subscriber) }
  end

  def update
    resource.update_attributes resource_params
    respond_with resource, location: -> { admin_subscriber_path(@subscriber) }
  end

  private

  def resource
    @subscriber ||= Subscriber.find(params[:id])
  end

  def resource_params
    params.require(:subscriber)
  end
end
