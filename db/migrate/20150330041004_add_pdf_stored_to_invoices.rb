class AddPdfStoredToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :pdf_stored, :boolean
  end
end
