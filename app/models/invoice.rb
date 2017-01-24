# frozen_string_literal: true
class Invoice < Receipt
  has_many :statement_entries

  validates :payment_id, presence: true, uniqueness: true

  before_validation :generate_payment_id, unless: :payment_id?
  before_save :fill_period, on: :create

  scope :not_due, -> { where("receipts.due_at > '#{DateTime.now}'") }
  scope :due, -> { where("receipts.due_at < '#{DateTime.now}'").where(reversed_at: nil) }
  scope :unpaid, -> { where(paid_at: nil) }
  scope :paid,   -> { where.not(paid_at: nil) }
  scope :unreversed, -> { where(reversed_at: nil) }
  scope :reversed,   -> { where.not(reversed_at: nil) }

  def balance
    paid_amount - total
  end

  def paid?
    paid_at? && paid_amount >= total
  end

  def reversed?
    reversed_at?
  end

  def due?
    return false if reversed?
    due_at <= DateTime.now
  end

  def late_days
    (Date.today - due_at.to_date).floor
  end

  def generate_payment_id
    return unless customer_id?
    self.payment_id ||= "#{customer_id}-#{receipt_id}"
  end

  def einvoice_path
    file_path('xml')
  end

  def eenvelope_path
    file_path('xml', 'env_')
  end

  def store_all_on_s3
    super
    store_einvoice
    return unless customer.einvoice?
    store_eenvelope
  end

  def einvoice_exists_on_s3?
    exists_on_s3?(einvoice_path)
  end

  def eenvelope_exists_on_s3?
    exists_on_s3?(eenvelope_path)
  end

  def store_einvoice
    store_to_s3(einvoice_path, einvoice_xml)
    einvoice_path
  end

  def store_eenvelope
    store_to_s3(eenvelope_path, eenvelope_xml)
    eenvelope_path
  end

  def einvoice_url
    s3_url(einvoice_path)
  end

  def eenvelope_url
    s3_url(eenvelope_path)
  end

  def einvoice
    EInvoice.new(invoice: self)
  end

  def einvoice_xml
    [
      '<?xml version="1.0" encoding="UTF-8"?>',
      '<IzdaniRacunEnostavni xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xds="http://uri.etsi.org/01903/v1.1.1#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.gzs.si/e-poslovanje/sheme/eSLOG_1-6_EnostavniRacun.xsd">',
      einvoice.generate,
      '</IzdaniRacunEnostavni>'
    ].join("\n")
  end

  def eenvelope
    EEnvelope.new(invoice: self)
  end

  def eenvelope_xml
    [
      '<?xml version="1.0" encoding="UTF-8"?>',
      '<package xmlns="hal:icl:01" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" pkg_type="einvoice">',
      eenvelope.generate,
      '</package>'
    ].join("\n")
  end

  def payment_id_full
    "SI00#{payment_id}"
  end

  def parse_iban_from_bank_data
    return unless bank_data
    return unless iban_string = bank_data.split("\n").first
    return unless iban_string.present?
    return unless IBANTools::IBAN.valid?(iban_string)
    iban_string
  end

  def to_s
    s = "Račun #{receipt_id} "
    if paid?
      return s + '(plačan)'
    else
      return s + '(neplačan)'
    end
  end

  def fill_period
    return if period_from || period_to
    
    self.period_from = Date.today
    self.period_to = Date.today
  end
end
