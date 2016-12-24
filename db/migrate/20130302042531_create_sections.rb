# frozen_string_literal: true
class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.string :name
      t.integer :position

      t.timestamps
    end
  end
end
