class CreateIntitutions < ActiveRecord::Migration
  def change
    create_table :intitutions do |t|
      t.string :name

      t.timestamps
    end
  end
end
