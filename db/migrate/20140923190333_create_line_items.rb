class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.integer :invoice_id
      t.string :entity_name
      t.string :product
      t.integer :quantity
      t.string :unit
      t.decimal :price_per_item
      t.decimal :discount_percent
      t.decimal :price_per_item_with_discount
      t.decimal :tax_percent
      t.decimal :tax
      t.decimal :subtotal
      t.decimal :total

      t.timestamps
    end
  end
end
