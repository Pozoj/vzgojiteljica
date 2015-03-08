class Entity < ActiveRecord::Base
  ENTITY_COMPANY = 1
  ENTITY_PERSON  = 2

  LITERAL_FILTERS = [:type, :vat_id]
  PARTIAL_FILTERS = [:title, :name, :address]

  belongs_to :post
  belongs_to :bank
  has_many :remarks, as: :remarkable, dependent: :destroy

  before_validation :format_account_number, if: :account_number?
  validates_presence_of :vat_id, if: :company?
  validate :validate_vat_id, if: :vat_id?
  validate :validate_name_or_title
  validate :validate_account_number, if: :account_number?
  validates :registration_number, numericality: {allow_nil: true, integer_only: true}
  validates :email, :email => true, if: :email?

  def to_s
    if name.present?
      return name
    else
      return title
    end
  end

  def customer?; self.is_a? Customer; end
  def subscriber?; self.is_a? Subscriber; end
  def person?
    self.is_a?(ContactPerson) ||
    self.is_a?(BillingPerson)
  end

  def self.pozoj
    where(email: 'info@pozoj.si').first
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

  def vat_id_formatted
    if company?
      "SI#{vat_id}" 
    else
      vat_id
    end
  end

  def iban
    return unless account_number?
    IBANTools::IBAN.new(account_number)
  end

  def account_number_formatted
    iban.prettify
  end

  def person?
    entity_type == ENTITY_PERSON
  end

  def company?
    entity_type == ENTITY_COMPANY
  end

  protected

  def format_account_number
    self.account_number = iban.try(:code)
  end

  def validate_name_or_title
    if !name? && !title?
      errors.add :base, 'Mora imeti ime ali naziv ali oboje'
    end
  end

  # http://www.durs.gov.si/si/storitve/vpis_v_davcni_register_in_davcna_stevilka/vpis_v_davcni_register_in_davcna_stevilka_pojasnila/davcna_stevilka_splosno/
  def validate_vat_id
    multipliers = [8, 7, 6, 5, 4, 3, 2]
    divider = 11
    digits = vat_id.to_s.split('').map(&:to_i)
    sum = multipliers.each_with_index.inject(0) { |sum, (multiplier, index)| sum += multiplier * digits[index] }

    if sum % divider == 1
      checksum = 0
    else
      checksum = divider - (sum % divider)
    end

    unless checksum == digits.last
      errors.add :vat_id, 'nepravilna številka (checksum)'
    end
  end

  def validate_account_number
    unless IBANTools::IBAN.valid?(account_number)
      errors.add :account_number, 'ni v IBAN obliki'
    end
  end
end
