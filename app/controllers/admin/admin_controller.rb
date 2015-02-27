class Admin::AdminController < ApplicationController
  before_filter :authenticate
  layout "admin"

  def index
    @last_issue = Issue.last
  end

  def quantities
    paid = params[:only_paid] == 'true'

    @quantities = Subscriber.all.group_by do |subscriber|
      quantity = subscriber.subscriptions.active
      quantity = quantity.paid if paid
      quantity = quantity.sum(:quantity)
    end.reject do |quantity, customers|
      quantity < 1
    end.sort_by do |quantity, customers|
      quantity
    end
  end
end
