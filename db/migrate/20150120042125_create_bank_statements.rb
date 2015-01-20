class CreateBankStatements < ActiveRecord::Migration
  def change
    create_table :bank_statements do |t|
      t.timestamps null: false
      t.datetime :processed_at
      t.text :raw_statement
      t.text :parsed_statement
    end

    add_attachment :bank_statements, :statement
  end
end
