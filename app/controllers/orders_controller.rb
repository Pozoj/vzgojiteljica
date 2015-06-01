class OrdersController < ApplicationController
  skip_before_filter :authenticate, only: [:new, :create, :successful]

  def index
    unless params[:all]
      @orders = collection.where(processed: false)
    end

    respond_with collection
  end

  def show
    @order = resource
  end

  def new
    @order = Order.new
    respond_with @order
  end

  def create
    # Honeypotz
    if params[:order][:desire] && params[:order][:desire].present?
      render :text => "Thank you for your order!"
      return
    end

    @order = Order.new params[:order]
    if @order.save
      AdminMailer.delay.new_order(@order.id)
      Mailer.delay.order_submitted(@order.id)
      redirect_to successful_orders_path
    else
      render action: :new
    end
  end

  def mark_processed
    resource.processed = true
    resource.save!
    redirect_to resource
  end

  private

  def resource
    @order ||= Order.find(params[:id])
  end

  def collection
    @orders ||= Order.page(params[:page]).order(created_at: :desc)
  end
end
