class AddInstitutionToAuthorships < ActiveRecord::Migration
  def change
    add_column :authorships, :institution_id, :integer
    add_index :authorships, :institution_id

    Author.all.each do |author|
      author.authorships.update_all(institution_id: author.institution_id)
    end
  end
end
