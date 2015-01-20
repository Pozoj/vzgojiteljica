class MoveAndAddFieldsToInvoices < ActiveRecord::Migration
  def change
    remove_column :invoices, :paid
    add_column :invoices, :paid_at, :datetime
    add_column :invoices, :paid_amount, :decimal
    add_column :invoices, :bank_data, :text

    add_index :invoices, :customer_id
    add_index :invoices, :reference_number
  end
end
