# frozen_string_literal: true
class AddPlanTypeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :plan_type, :integer
  end
end
