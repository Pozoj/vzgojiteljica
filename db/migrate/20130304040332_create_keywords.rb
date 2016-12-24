# frozen_string_literal: true
class CreateKeywords < ActiveRecord::Migration
  def change
    create_table :keywords do |t|
      t.string :keyword

      t.timestamps
    end

    add_index :keywords, :keyword, unique: true

    # Add keywords_string cache to articles.
    add_column :articles, :keywords_string, :string
  end
end
