class CreateAuthorships < ActiveRecord::Migration
  def change
    create_table :authorships do |t|
      t.integer :article_id
      t.integer :author_id
      t.integer :position, default: 1
      t.timestamps
    end
    add_index :authorships, :article_id
    add_index :authorships, :author_id
    add_index :authorships, [:author_id, :article_id], unique: true
  end
end
