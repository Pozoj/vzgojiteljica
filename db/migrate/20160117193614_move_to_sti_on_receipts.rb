# frozen_string_literal: true
class MoveToStiOnReceipts < ActiveRecord::Migration
  def change
    rename_column :receipts, :invoice_id, :receipt_id

    add_column :receipts, :type, :string
    add_index :receipts, :type

    Receipt.update_all(type: 'Invoice')
  end
end
