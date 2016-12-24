# frozen_string_literal: true
class AddIndexOnPaidToInvoices < ActiveRecord::Migration
  def change
    add_index :invoices, :paid_at
  end
end
