class DropUnneededFields < ActiveRecord::Migration
  def change
    remove_column :subscriptions, :order_id
    remove_column :subscriptions, :order_form
  end
end
