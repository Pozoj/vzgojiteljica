class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name
      t.decimal :price
      t.integer :billing_frequency
      t.integer :batch_id

      t.timestamps
    end
  end
end
