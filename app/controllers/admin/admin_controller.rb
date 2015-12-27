class Admin::AdminController < ApplicationController
  before_filter :authenticate, :try_set_page_title
  layout "admin"

  def index
    @invoices = Invoice.where(year: 2015)
  end

  def quantities
    @page_title = 'Količine po prejemnikih'

    @paid = params[:only_paid] == 'true'

    @which = params[:which]
    klass = if @which == 'customers'
      Customer
    else
      Subscriber
    end

    @quantities = klass.all.group_by do |entity|
      quantity = entity.subscriptions.active
      quantity = quantity.paid if @paid
      quantity = quantity.sum(:quantity)
    end.reject do |quantity, entities|
      quantity < 1
    end.sort_by do |quantity, entities|
      quantity
    end
  end

  def freeriders
    @page_title = 'Brezplačniki'
    @freeriders = Subscription.free.active.order(start: :desc)
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
    end.reject do |region, customers|
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
