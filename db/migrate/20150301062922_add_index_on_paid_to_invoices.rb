class AddIndexOnPaidToInvoices < ActiveRecord::Migration
  def change
    add_index :invoices, :paid_at
  end
end
