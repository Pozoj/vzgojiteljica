# frozen_string_literal: true
class RenameInvoicesToReceipts < ActiveRecord::Migration
  def change
    rename_table :invoices, :receipts
  end
end
