class KeywordablesIdsToInteger < ActiveRecord::Migration
  def change
    change_column :keywordables, :article_id, :integer
    change_column :keywordables, :keyword_id, :integer
  end
end
