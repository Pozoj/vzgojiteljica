class CreateKeywordables < ActiveRecord::Migration
  def change
    create_table :keywordables do |t|
      t.string :keyword_id
      t.string :article_id

      t.timestamps
    end

    add_index :keywordables, :keyword_id
    add_index :keywordables, :article_id
    add_index :keywordables, [:keyword_id, :article_id], unique: true
    add_index :keywordables, [:article_id, :keyword_id], unique: true
  end
end
