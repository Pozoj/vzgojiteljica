# frozen_string_literal: true
class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :title
      t.string :name
      t.string :address
      t.integer :post_id
      t.string :phone
      t.string :fax
      t.string :email
      t.string :vat_id
      t.string :place_and_date
      t.text :comments
      t.integer :quantity
      t.string :ip

      t.timestamps
    end
  end
end
