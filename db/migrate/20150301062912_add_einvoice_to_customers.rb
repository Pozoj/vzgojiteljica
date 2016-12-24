# frozen_string_literal: true
class AddEinvoiceToCustomers < ActiveRecord::Migration
  def change
    add_column :entities, :einvoice, :boolean
    add_index :entities, :einvoice
  end
end
