class CreateCopies < ActiveRecord::Migration
  def change
    create_table :copies do |t|
      t.string :page_code
      t.text :copy
      t.text :copy_html

      t.timestamps
    end
  end
end
