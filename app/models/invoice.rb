class Invoice < ActiveRecord::Base
  include Invoicing

  monetize :subtotal_cents
  monetize :total_cents
  monetize :paid_amount_cents
  monetize :tax_cents

  belongs_to :customer
  has_many :issues, through: :line_items
  has_many :remarks, as: :remarkable
  has_many :line_items, dependent: :destroy

  validates_presence_of :customer
  validates :year, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :reference_number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :invoice_id, presence: true, uniqueness: true
  validates :payment_id, presence: true, uniqueness: true
  validates :total, presence: true, numericality: true
  validates :subtotal, presence: true, numericality: true
  validates :tax, presence: true, numericality: true

  before_validation :generate_year, unless: :year?
  before_validation :generate_invoice_id, unless: :invoice_id?
  before_validation :generate_payment_id, unless: :payment_id?

  before_save :calculate_totals, on: :create

  scope :unpaid, -> { where(paid_at: nil) }
  scope :paid,   -> { where.not(paid_at: nil) }

  def self.match_to_statements!
    Invoice.unpaid.each do |i|
      next unless i.match_statement_entry
      next unless i.match_statement_entry.amount == i.total
      i.paid_by! i.match_statement_entry
    end
  end

  def self.years
    years = Invoice.select(:year).group(:year).map(&:year)
    years << DateTime.now.year
    years.sort.reverse.uniq
  end

  def paid?
    paid_at? && paid_amount == total
  end

  def paid_by!(statement)
    self.paid_at = statement.date
    self.paid_amount = statement.amount
    self.bank_data = statement.details
    self.bank_reference = statement.reference
    save!

    # We destroy statement entries that we process.
    statement.destroy
  end

  def due?
    due_at <= DateTime.now
  end

  def late_days
    (Date.today - due_at.to_date).floor
  end

  def generate_year
    self.year ||= created_at.try(:year) || DateTime.now.year
  end

  def generate_invoice_id
    self.invoice_id ||= "#{reference_number}-#{year}"
  end

  def generate_payment_id
    return unless customer_id?
    self.payment_id ||= "#{customer_id}-#{invoice_id}"
  end

  def pdf
    pdf_generator = PdfGenerator.new
    pdf_generator.convert_url("http://www.vzgojiteljica.si/admin/invoices/#{id}/print")
  end

  def pdf_idempotent
    return pdf_url if pdf_stored?
    store_pdf
    pdf_url
  end

  def file_path(extension, prefix = "")
    "invoices/#{year}/#{prefix}#{invoice_id}.#{extension}"
  end

  def pdf_path; file_path('pdf'); end
  def einvoice_path; file_path('xml'); end
  def eenvelope_path; file_path('xml', 'env_'); end

  def store_to_s3(path, data)
    s3_connection.directories.new(:key => AWS_S3['bucket']).files.create(
      :key    => path,
      :body   => data,
      :public => false
    )
  end

  def exists_on_s3?(path)
    !!s3_connection.directories.new(:key => AWS_S3['bucket']).files.head(path)
  end
  def pdf_exists_on_s3?; exists_on_s3?(pdf_path); end
  def einvoice_exists_on_s3?; exists_on_s3?(einvoice_path); end
  def eenvelope_exists_on_s3?; exists_on_s3?(eenvelope_path); end

  def store_pdf
    store_to_s3(pdf_path, pdf)
    self.pdf_stored = true
    self.save
    pdf_path
  end
  def store_einvoice; store_to_s3(einvoice_path, einvoice_xml); einvoice_path; end
  def store_eenvelope; store_to_s3(eenvelope_path, eenvelope_xml); eenvelope_path; end

  def s3_url(path)
    s3_connection.directories.new(:key => AWS_S3['bucket']).files.new(:key => path).url(1.hour.from_now)
  end
  def pdf_url; s3_url(pdf_path); end
  def einvoice_url; s3_url(einvoice_path); end
  def eenvelope_url; s3_url(eenvelope_path); end

  def s3_connection
    @s3_connection ||= Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => AWS_S3['access_key_id'],
      :aws_secret_access_key    => AWS_S3['secret_access_key']
    })
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

  def match_statement_entry
    query = "%SI00#{reference_number}%"
    @statement_entry ||= StatementEntry.where(StatementEntry.arel_table[:details].matches(query)).first
  end

  def parse_iban_from_bank_data
    return unless bank_data
    return unless iban_string = bank_data.split("\n").first
    return unless iban_string.present?
    return unless IBANTools::IBAN.valid?(iban_string)
    iban_string
  end

  def calculate_totals
    self.tax_percent = TAX_PERCENT
    self.tax         = line_items.to_a.sum(&:tax)
    self.subtotal    = line_items.to_a.sum(&:subtotal)
    self.total       = line_items.to_a.sum(&:total)
  end

  def to_param
    invoice_id
  end
end
