class AddFieldsForOrderForms < ActiveRecord::Migration
  def change
    add_column :invoices, :order_form, :string
    add_column :subscriptions, :order_form, :string
  end
end
