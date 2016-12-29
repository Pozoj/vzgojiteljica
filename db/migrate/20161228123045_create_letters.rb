class CreateLetters < ActiveRecord::Migration
  def change
    create_table :letters do |t|
      t.string :title
      t.text :body
      t.text :body_html

      t.timestamps null: false
    end
  end
end
