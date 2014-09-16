class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :subscription_id
      t.integer :issue_id
      t.date :due_at
      t.decimal :subtotal
      t.decimal :total
      t.decimal :tax
      t.decimal :tax_percent
      t.boolean :paid
      t.integer :reference_number

      t.timestamps
    end

    add_index :invoices, :subscription_id
    add_index :invoices, :issue_id
  end
end
