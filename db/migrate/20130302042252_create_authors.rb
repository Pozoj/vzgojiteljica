# frozen_string_literal: true
class CreateAuthors < ActiveRecord::Migration
  def change
    create_table :authors do |t|
      t.string :first_name
      t.string :last_name
      t.string :address
      t.integer :post_id
      t.string :email
      t.text :notes
      t.integer :institution_id
      t.string :phone
      t.string :title
      t.string :education

      t.timestamps
    end
  end
end
