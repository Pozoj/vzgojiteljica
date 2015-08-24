class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :user_id
      t.string :event
      t.text :details
      t.string :eventable_type
      t.integer :eventable_id

      t.timestamps
    end

    add_index :events, :user_id
    add_index :events, :eventable_id
    add_index :events, :eventable_type
    add_index :events, :event
  end
end

