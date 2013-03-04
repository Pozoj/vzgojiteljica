class RemoveKeywordsFieldsFromArticlesAndIssues < ActiveRecord::Migration
  def change
    remove_column :articles, :keywords
    remove_column :issues, :keywords
  end
end
