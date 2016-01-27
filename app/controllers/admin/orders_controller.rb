class Admin::OrdersController < Admin::AdminController
  def index
    @orders = Order.all.order(created_at: :desc).page(params[:page]).per(20)
  end

  def show
    resource
  end

  def destroy
    order = Order.find(params[:id])
    if order.destroy
      redirect_to admin_orders_path, notice: "Naročilo uspešno izbrisano"
    end
  end

  private

  def resource
    @order ||= Order.find(params[:id])
  end

  def set_page_title
    @page_title = 'Naročila'
  end
end
