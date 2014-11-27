class AddPlanTypeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :plan_type, :integer
  end
end
