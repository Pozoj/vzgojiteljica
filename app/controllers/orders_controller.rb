# frozen_string_literal: true
class OrdersController < ApplicationController
  skip_before_filter :authenticate, only: [:new, :create, :successful]

  def new
    @order = Order.new
    respond_with @order
  end

  def create
    # Honeypotz
    if params[:order][:desire] && params[:order][:desire].present?
      render text: 'Thank you for your order!'
      return
    end

    @order = Order.new params[:order]
    @order.ip = request.remote_ip
    if @order.save
      AdminMailer.delay.new_order(@order.id)
      Mailer.delay.order_submitted(@order.id)
      redirect_to successful_orders_path
    else
      render action: :new
    end
  end

  private

  def resource
    return unless params[:id]
    @order ||= Order.find(params[:id])
  end
end
