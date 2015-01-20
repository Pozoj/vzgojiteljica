class CreateStatementEntries < ActiveRecord::Migration
  def change
    create_table :statement_entries do |t|
      t.string :account_holder
      t.string :account_number
      t.money :amount
      t.date :date
      t.string :details
      t.integer :bank_statement_id
      t.string :reference

      t.timestamps null: false
    end

    add_index :statement_entries, :reference, unique: true
    add_index :statement_entries, :bank_statement_id
  end
end
