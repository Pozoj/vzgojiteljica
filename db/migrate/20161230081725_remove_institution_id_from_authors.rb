class RemoveInstitutionIdFromAuthors < ActiveRecord::Migration
  def change
    remove_column :authors, :institution_id
  end
end
