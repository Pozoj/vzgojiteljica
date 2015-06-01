class AddOrderIdToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :order_id, :integer
    add_index :subscriptions, :order_id
  end
end
