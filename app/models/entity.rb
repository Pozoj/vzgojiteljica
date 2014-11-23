class Entity < ActiveRecord::Base
  LITERAL_FILTERS = [:type]
  PARTIAL_FILTERS = [:title, :name, :address, :vat_id]

  belongs_to :post
  has_many :remarks, as: :remarkable

  def to_s
    title || name
  end

  def customer?; self.is_a? Customer; end
  def subscriber?; self.is_a? Subscriber; end
  def person?
    self.is_a?(ContactPerson) ||
    self.is_a?(BillingPerson)
  end

  def self.search filters
    filters ||= {}
    entities = all
    return entities if filters.empty?

    LITERAL_FILTERS.each do |filter|
      next unless filters[filter]
      next if filters[filter].blank?
      entities = entities.where(filter => filters[filter])
    end

    PARTIAL_FILTERS.each do |filter|
      next unless filters[filter]
      next if filters[filter].blank?
      entities = entities.where(Entity.arel_table[filter].matches("%#{filters[filter]}%"))
    end

    if filters[:global] && filters[:global].present?
      query = nil
      PARTIAL_FILTERS.each do |filter|
        unless query
          query = Entity.arel_table[filter].matches("%#{filters[:global]}%")
          next
        end
        query = query.or(Entity.arel_table[filter].matches("%#{filters[:global]}%"))
      end
      entities = entities.where query
    end

    entities
  end

  def customer
    if customer?
      return self
    elsif subscriber?
      subscription.customer
    elsif respond_to? :entity
      if entity && entity.customer?
        entity
      elsif entity && entity.subscriber?
        entity.customer
      end
    end
  end
end
