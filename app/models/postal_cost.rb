class PostalCost < ActiveRecord::Base
  validate :validate_weight

  WEIGHT_TYPES = [
    [0, 700, 'NDP'],
    [700, 2000, 'Navadno pismo'],
    [2000, 20000, 'Navadni paket']
  ].freeze

  def self.type_for_weight(weight)
    WEIGHT_TYPES.find do |wt|
      weight > wt[0] && weight <= wt[1]
    end.try(:last)
  end

  def self.calculate_for_weight(weight)
    where(service_type: type_for_weight(weight))
      .where('weight_from < ?', weight)
      .where('weight_to >= ?', weight)
      .first
  end

  private

  def validate_weight
    return if weight_from && weight_to && weight_from < weight_to
    errors.add(:base, 'weight_from has to be larger than weight_to')
  end
end
