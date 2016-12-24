# frozen_string_literal: true
class AddReversedAtToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :reversed_at, :datetime
    add_column :invoices, :reverse_reason, :string
  end
end
