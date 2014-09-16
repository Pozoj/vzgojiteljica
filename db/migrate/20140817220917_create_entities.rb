class CreateEntities < ActiveRecord::Migration
  def change
    create_table :entities do |t|
      t.string :title
      t.string :name
      t.string :address
      t.integer :post_id, limit: 4
      t.string :city
      t.string :phone
      t.string :email
      t.string :vat_id
      t.boolean :vat_exempt
      t.string :type
      t.integer :quantity
      t.integer :entity_id
      t.integer :subscription_id

      t.timestamps
    end

    add_index :entities, :entity_id
    add_index :entities, :subscription_id
    add_index :entities, :post_id
  end
end
