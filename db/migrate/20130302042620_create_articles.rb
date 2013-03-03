class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.integer :author_id
      t.integer :section_id
      t.integer :issue_id
      t.string :title
      t.text :abstract
      t.text :abstract_html
      t.text :abstract_english
      t.text :abstract_english_html
      t.string :keywords

      t.timestamps
    end
  end
end
