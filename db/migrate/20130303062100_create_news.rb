# frozen_string_literal: true
class CreateNews < ActiveRecord::Migration
  def change
    create_table :news do |t|
      t.string :title
      t.text :body
      t.text :body_html
      t.string :author

      t.timestamps
    end
  end
end
