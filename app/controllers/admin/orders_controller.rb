class Admin::OrdersController < Admin::AdminController
  def index
    @orders = Order.all.order(created_at: :desc).page(params[:page]).per(20)
    if params[:all] != 'true'
      @orders = @orders.not_processed
    end
  end

  def mark_processed
    order = Order.find(params[:id])
    order.processed!(current_user.id)
    if order.reload.processed?
      redirect_to admin_order_path(order), notice: "Označeno kot sprocesirano"
    else
      redirect_to admin_order_path(order)
    end
  end

  def show
    @order = Order.find(params[:id])

    customers = Customer.all.order(:title, :name)
    if @order.post_id
      customers = customers.where(post_id: @order.post_id)
    end
    
    @all_subscribers = customers.map do |c|
      [
        c.to_s,
        c.subscribers.select(:id, :title, :name).order(:title, :name).map { |s| ["#{s}", s.id] }
      ]
    end
  end
end
