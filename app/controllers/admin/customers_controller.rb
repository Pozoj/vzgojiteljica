class Admin::CustomersController < Admin::AdminController
  has_scope :page, :default => 1

  def show
    respond_with resource
  end

  def new_freerider
    @customer = Customer.new
  end


# "customer"=>{"remark"=>{"remark"=>"Znanstveni clanek"}, "title"=>"Simon", "name"=>"Talekov Simon", "address"=>"Ratatujeva 21", "post_id"=>"3320", "subscription"=>{"quantity"=>"1", "free_type"=>"1"}}


  def create_freerider
    @customer = Customer.new
    @subscriber = @customer.subscribers.build
    customer_params = params.require(:customer)
    @customer.title   = @subscriber.title   = customer_params[:title]
    @customer.name    = @subscriber.name    = customer_params[:name]
    @customer.address = @subscriber.address = customer_params[:address]
    @customer.post_id = @subscriber.post_id = customer_params[:post_id]

    @customer.save
    @subscriber.save

    # Remarks
    if customer_params[:remark] && customer_params[:remark][:remark].present?
      @customer.remarks.create remark: customer_params[:remark][:remark]
    end

    # Subscription
    if customer_params[:subscription]
      @subscription = @subscriber.subscriptions.build
      @subscription.plan = Plan.free
      @subscription.start = DateTime.now
      @subscription.quantity = customer_params[:subscription][:quantity]
      # Type
      type = customer_params[:subscription][:free_type]
      @subscription.end = if type == "1"
        DateTime.now.end_of_month
      elsif type == "2"
        DateTime.now.end_of_year
      elsif type == "3"
        # No end for now.
      end

      if @subscription.save
        redirect_to admin_subscription_path(@subscription)
        return
      end
    end

    render action: :new_freerider
  end

  def new_from_order
    @customer = Customer.new_from_order(params[:order_id])
    if @customer.try(:persisted?)
      redirect_to admin_customer_path(@customer)
    else
      redirect_to orders_path(error: @customer.errors.join(', ').inspect)
    end
  end

  def new
    @customer = Customer.new
    respond_with resource
  end

  def create
    @customer = Customer.create resource_params
    respond_with resource, location: -> { admin_customer_path(@customer) }
  end

  def edit
    respond_with resource, location: -> { admin_customer_path(@customer) }
  end

  def update
    resource.update_attributes resource_params
    if resource.valid?
      respond_with resource, location: -> { admin_customer_path(@customer) }
    else
      respond_with resource, location: -> { edit_admin_customer_path(@customer) }
    end
  end

  def destroy
    resource.destroy
    respond_with resource, location: -> { admin_entities_path }
  end

  private

  def resource
    @customer ||= Customer.find(params[:id])
  end

  def resource_params
    params.require(:customer)
  end
end
