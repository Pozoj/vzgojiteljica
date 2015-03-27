class Admin::CustomersController < Admin::AdminController
  has_scope :page, :default => 1

  def show
    respond_with resource
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
