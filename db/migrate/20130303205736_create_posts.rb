class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts, :id => false do |t|
      t.integer :id
      t.string :name

      t.timestamps
    end
  end
end
