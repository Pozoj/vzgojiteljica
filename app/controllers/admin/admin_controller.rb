class Admin::AdminController < ApplicationController
  before_filter :authenticate
  layout "admin"

  def index
    @last_issue = Issue.last
  end

  def quantities
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
    @freeriders = Subscription.free.active.order(:start)
  end

  def regional
    paid = params[:only_paid] == 'true'

    customers = Customer.all.reject { |customer| customer.subscriptions.active.empty? }
    @regional = customers.group_by { |customer| customer.post.regional_master_id }
  end
end
