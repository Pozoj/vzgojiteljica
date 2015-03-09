class AddFieldsToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :payment_id, :string
    add_index  :invoices, :payment_id, unique: true

    add_column :invoices, :invoice_id, :string
    add_index  :invoices, :invoice_id, unique: true

    add_column :invoices, :year, :integer
    add_index  :invoices, :year

    Invoice.all.each do |invoice|
      invoice.generate_year
      invoice.generate_invoice_id
      invoice.generate_payment_id
      invoice.save
    end
  end
end
