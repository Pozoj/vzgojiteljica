class Entity < ActiveRecord::Base
  ENTITY_COMPANY = 1
  ENTITY_PERSON  = 2

  GLOBAL_FILTERS  = [:title, :name, :address]
  LITERAL_FILTERS = [:type, :einvoice, :entity_type, :vat_id]
  PARTIAL_FILTERS = [:title, :name, :address]

  belongs_to :post
  belongs_to :bank
  has_many :remarks, as: :remarkable, dependent: :destroy

  before_validation :format_account_number, if: :account_number?
  validates :vat_id, presence: true, if: :company?
  validates :vat_id, uniqueness: {allow_nil: true}, numericality: {only_integer: true, allow_nil: true, greater_than: 0}
  validate :validate_vat_id, if: :vat_id?
  validate :validate_name_or_title
  validate :validate_account_number
  validates :registration_number, uniqueness: {allow_nil: true}, numericality: {allow_nil: true, only_integer: true, greater_than: 0}
  validates :email, :email => true, if: :email?

  scope :person,      -> { where(entity_type: ENTITY_PERSON) }
  scope :not_person,  -> { where.not(entity_type: ENTITY_PERSON) }
  scope :company,     -> { where(entity_type: ENTITY_COMPANY) }
  scope :not_company, -> { where.not(entity_type: ENTITY_COMPANY) }

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

  def pozoj?
    email == 'info@pozoj.si'
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
      GLOBAL_FILTERS.each do |filter|
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
    if company? && !vat_exempt?
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

  def string_description
    [
      name,
      title,
      address,
      post,
      'Slovenija',
      email,
      "Davčna št.: #{vat_id_formatted}",
      "Matična št.: #{registration_number}",
    ].compact.map(&:to_s).join(', ')
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
  def vat_id_checksum_matches?
    multipliers = [8, 7, 6, 5, 4, 3, 2]
    divider = 11
    digits = vat_id.to_s.split('').map(&:to_i)
    sum = multipliers.each_with_index.inject(0) { |sum, (multiplier, index)| sum += multiplier * digits[index] }

    checksum = if sum % divider == 1
      0
    else
      divider - (sum % divider)
    end

    checksum == digits.last
  end

  def validate_vat_id
    unless vat_id.to_s.length == 8
      errors.add :vat_id, 'nepravilne dolžine'
      return
    end

    unless vat_id_checksum_matches?
      errors.add :vat_id, 'nepravilna številka (checksum)'
    end
  end

  def validate_account_number
    if account_number.blank?
      self.account_number = nil
    end

    return unless account_number?
    
    unless IBANTools::IBAN.valid?(account_number)
      errors.add :account_number, 'ni v IBAN obliki'
    end
  end
end
