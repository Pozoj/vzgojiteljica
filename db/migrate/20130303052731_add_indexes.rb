# frozen_string_literal: true
class AddIndexes < ActiveRecord::Migration
  def change
    add_index :authors, :post_id
    add_index :authors, :institution_id

    add_index :copies, :page_code

    add_index :issues, :year
    add_index :issues, :issue

    add_index :articles, :author_id
    add_index :articles, :issue_id
    add_index :articles, :section_id
  end
end
