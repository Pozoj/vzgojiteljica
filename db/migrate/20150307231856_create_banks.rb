class CreateBanks < ActiveRecord::Migration
  def change
    create_table :banks do |t|
      t.string :name
      t.string :bic

      t.timestamps null: false
    end
    add_index :banks, :bic, unique: true
  end
end
