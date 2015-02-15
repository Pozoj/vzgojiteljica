class Admin::CustomersController < Admin::AdminController
  has_scope :page, :default => 1

  def new
    @customer = Customer.new
  end

  def show
    respond_with resource
  end

  def new_from_order
    @order = Order.find(params[:order_id])

    @customer = Customer.new
    @customer.title = @order.title
    @customer.name = @order.name
    @customer.address = @order.address
    @customer.post_id = @order.post_id
    @customer.phone = @order.phone
    @customer.email = @order.email
    @customer.vat_id = @order.vat_id
    @customer.save!

    @customer.remarks.create remark: "Naročnik ustvarjen avtomatsko iz naročila ##{@order.id} na spletni strani."

    @subscriber = @customer.subscribers.new
    @subscriber.title = @order.title
    @subscriber.name = @order.name
    @subscriber.address = @order.address
    @subscriber.post_id = @order.post_id
    @subscriber.save!

    if @order.comments.present?
      @subscriber.remarks.create remark: "Opomba naročnika: \"#{@order.comments}\""
    end

    @subscription = @subscriber.subscriptions.new
    @subscription.start = Date.today
    @subscription.quantity = @order.quantity
    if @order.plan_type
      @subscription.plan = Plan.latest(@order.plan_type)
    end
    @subscription.save!

    @order.processed = true
    @order.save!

    redirect_to admin_customer_path(@customer)
  end

  private

  def resource
    @customer ||= Customer.find(params[:id])
  end
end
