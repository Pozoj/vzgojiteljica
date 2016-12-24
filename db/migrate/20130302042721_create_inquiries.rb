# frozen_string_literal: true
class CreateInquiries < ActiveRecord::Migration
  def change
    create_table :inquiries do |t|
      t.string :name
      t.string :institution
      t.string :email
      t.string :phone
      t.boolean :show
      t.string :subject
      t.text :question
      t.text :answer

      t.timestamps
    end
  end
end
