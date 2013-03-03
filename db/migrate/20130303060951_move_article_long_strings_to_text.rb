class MoveArticleLongStringsToText < ActiveRecord::Migration
  def change
    change_column :articles, :title, :text
    change_column :articles, :keywords, :text
  end
end
