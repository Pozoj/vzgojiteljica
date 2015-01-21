class OrdersController < ApplicationController
  before_filter :authenticate
  skip_before_filter :authenticate, only: [:new, :create]

  def index
    unless params[:all]
      @orders = collection.where(processed: false)
    end

    respond_with collection
  end

  def new
    @order = Order.new
    respond_with @order
  end

  def create
    @order = Order.new params[:order]
    if @order.save
      AdminMailer.new_order(@order.id).deliver
      redirect_to root_url notice: "Hvala! Vaše naročilo je bilo uspešno sprejeto."
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
    @orders ||= Order.page(params[:page])
  end

    def resource_params
      return [] if request.get?
      [params.require(:order).permit(:title, :name, :address, :post_id, :phone, :fax, :email, :vat_id, :place_and_date, :comments, :quantity)]
    end
end