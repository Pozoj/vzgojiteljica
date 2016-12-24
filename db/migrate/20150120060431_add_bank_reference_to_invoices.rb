# frozen_string_literal: true
class AddBankReferenceToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :bank_reference, :string
    add_index :invoices, :bank_reference, unique: true
  end
end
