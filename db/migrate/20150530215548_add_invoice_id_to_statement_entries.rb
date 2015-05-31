class AddInvoiceIdToStatementEntries < ActiveRecord::Migration
  def change
    add_column :statement_entries, :invoice_id, :integer
    add_index :statement_entries, :invoice_id

    rename_column :statement_entries, :reference, :bank_reference
    
    add_column :statement_entries, :reference, :string
    add_index :statement_entries, :reference

    add_column :statement_entries, :matched, :boolean, default: false
    add_index :statement_entries, :matched
  end
end
