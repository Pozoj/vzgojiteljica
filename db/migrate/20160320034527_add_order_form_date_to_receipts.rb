class AddOrderFormDateToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :order_form_date, :date
  end
end
