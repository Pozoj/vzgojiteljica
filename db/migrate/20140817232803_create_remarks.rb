# frozen_string_literal: true
class CreateRemarks < ActiveRecord::Migration
  def change
    create_table :remarks do |t|
      t.integer :user_id
      t.text :remark
      t.string :remarkable_type
      t.integer :remarkable_id

      t.timestamps
    end
  end
end
