# frozen_string_literal: true
class Admin::AdminController < ApplicationController
  before_filter :authenticate, :try_set_page_title
  layout 'admin'

  def index
    @invoices = Invoice.where(year: Date.today.year)
    @order_forms = OrderForm.not_processed.count
  end

  def quantities
    @page_title = 'Količine po prejemnikih'

    @paid = params[:only_paid] == 'true'
    @free = params[:only_free] == 'true'
    @rewards = params[:only_rewards] == 'true'
    @except_rewards = params[:except_rewards] == 'true'

    @which = params[:which]
    klass = if @which == 'customers'
              Customer
            else
              Subscriber
    end

    @quantities = klass.all.group_by do |entity|
      quantity = entity.subscriptions.active

      if @paid
        quantity = quantity.paid
      elsif @free
        quantity = quantity.free
      elsif @rewards
        quantity = quantity.free.rewards
      elsif @except_rewards
        quantity = quantity.without_rewards
      end

      quantity = quantity.sum(:quantity)
    end.reject do |quantity, _entities|
      quantity < 1
    end.sort_by do |quantity, _entities|
      quantity
    end
  end

  def controls
    @page_title = 'Kontrola pakiranja'

    @paid = params[:only_paid] == 'true'
    @free = params[:only_free] == 'true'
    @rewards = params[:only_rewards] == 'true'
    @except_rewards = params[:except_rewards] == 'true'

    subscriptions = Subscription.active
    if @paid
      subscriptions = subscriptions.paid
    elsif @free
      subscriptions = subscriptions.free
    elsif @rewards
      subscriptions = subscriptions.free.rewards
    elsif @except_rewards
      subscriptions = subscriptions.without_rewards
    end

    @subscribers = subscriptions.group_by(&:subscriber).sort_by do |subscriber, subs|
      -subs.sum(&:quantity)
    end.map do |subscriber, subs|
      {
        subscriber: subscriber,
        quantity: subs.sum(&:quantity)
      }
    end
  end

  def freeriders
    @page_title = 'Brezplačniki'
    @freeriders = Subscription.free.active.order(start: :desc, id: :asc)
  end

  def regional
    @page_title = 'Količine po regijah'
    customers = Customer.all.order(:post_id).reject do |customer|
      subscriptions = customer.subscriptions.active.empty?
    end

    @total_customers = 0
    @total_quantity = 0

    @regional = customers.group_by do |customer|
      customer.post.try(:master)
    end.reject do |region, _customers|
      region.nil?
    end.map do |region, customers|
      customers_count = customers.count
      @total_customers += customers_count
      quantities_count = customers.inject(0) { |sum, customer| sum += customer.subscriptions.active.sum(:quantity) }
      @total_quantity += quantities_count

      [region, {
        customers_count: customers_count,
        quantities_count: quantities_count
      }]
    end

    @total_customers = customers.count
    @total_quantity = Subscription.active.sum(:quantity)
  end

  private

  def try_set_page_title
    if respond_to?(:resource, true) && resource.present?
      @page_title = resource.to_s
    elsif respond_to?(:set_page_title, true)
      set_page_title
    end
  end
end
