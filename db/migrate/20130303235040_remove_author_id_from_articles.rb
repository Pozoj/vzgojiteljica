# frozen_string_literal: true
class RemoveAuthorIdFromArticles < ActiveRecord::Migration
  def change
    remove_column :articles, :author_id
  end
end
