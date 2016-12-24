# frozen_string_literal: true
class MoveLineItemsToReceipts < ActiveRecord::Migration
  def change
    rename_column :line_items, :invoice_id, :receipt_id
  end
end
