class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.integer :year
      t.integer :issue
      t.date :published_at
      t.string :keywords

      t.timestamps
    end
  end
end
