# frozen_string_literal: true
class CreateBatches < ActiveRecord::Migration
  def change
    create_table :batches do |t|
      t.string :name
      t.decimal :price
      t.integer :issues_per_year

      t.timestamps
    end
  end
end
