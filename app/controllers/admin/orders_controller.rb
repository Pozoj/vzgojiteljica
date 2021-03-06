# frozen_string_literal: true
class Admin::OrdersController < Admin::AdminController
  def index
    @orders = Order.all.order(created_at: :desc).page(params[:page]).per(20)
    return if params[:filter_all]

    @orders = @orders.not_processed
  end

  def show
    resource
  end

  def destroy
    order = Order.find(params[:id])
    if order.destroy
      redirect_to admin_orders_path, notice: 'Naročilo uspešno izbrisano'
    end
  end

  private

  def resource
    @order ||= Order.find_by(id: params[:id])
  end

  def set_page_title
    @page_title = 'Naročila'
  end
end
