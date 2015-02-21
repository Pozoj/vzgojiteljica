class Admin::AdminController < ApplicationController
  before_filter :authenticate
  layout "admin"

  def index
    @last_issue = Issue.last
  end

  def quantities
    @quantities = Customer.all.group_by do |customer|
      customer.subscriptions.active.sum(:quantity)
    end.reject do |quantity, customers|
      quantity < 1
    end.sort_by do |quantity, customers|
      quantity
    end
  end
end
