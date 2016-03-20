class Admin::SubscribersController < Admin::AdminController
  has_scope :page, :default => 1

  def show
    @remarks = resource.global_remarks
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

  def destroy
    resource.destroy
    respond_with resource, location: -> { admin_customer_path(resource.customer) }
  end

  private

  def resource
    return unless params[:id]
    @subscriber ||= Subscriber.find(params[:id])
  end

  def resource_params
    params.require(:subscriber)
  end

  def set_page_title
    @page_title = 'Prejemniki'
  end
end
