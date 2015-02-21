class Admin::AdminController < ApplicationController
  before_filter :authenticate
  layout "admin"

  def index
    @last_issue = Issue.last
  end

  def quantities
    @quantities = Subscriber.all.group_by do |subscriber|
      subscriber.subscriptions.active.sum(:quantity)
    end.reject do |quantity, customers|
      quantity < 1
    end.sort_by do |quantity, customers|
      quantity
    end
  end
end
