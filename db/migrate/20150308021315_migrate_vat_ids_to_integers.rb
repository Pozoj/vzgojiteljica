class MigrateVatIdsToIntegers < ActiveRecord::Migration
  def change
    entities = Entity.where.not(vat_id: nil).map { |e| [e.id, e.vat_id] }

    change_column :entities, :vat_id, :integer, limit: 8

    entities.each do |e|
      entity = Entity.find(e.first)
      vat_id = e.last

      if vat_id.blank? || vat_id == "0"
        print 's'
        next
      end

      entity.vat_id = vat_id
      entity.entity_type = Entity::ENTITY_COMPANY
      
      unless entity.valid?
        puts
        puts "INVALID VAT ID #{entity.to_json} #{entity.errors.inspect}"
        puts
        next
      end

      entity.save
      print '.'
    end

    puts "DONE"
  end
end
