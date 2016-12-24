# frozen_string_literal: true
class Receipt < ActiveRecord::Base
  include Invoicing

  attr_accessor :skip_s3

  monetize :subtotal_cents
  monetize :total_cents
  monetize :paid_amount_cents
  monetize :tax_cents

  belongs_to :customer
  has_many :remarks, as: :remarkable, dependent: :destroy
  has_many :events, as: :eventable, dependent: :destroy
  has_many :line_items, dependent: :destroy
  has_many :issues, through: :line_items

  validates_presence_of :customer
  validates :year, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :reference_number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :receipt_id, presence: true, uniqueness: { scope: :type }
  validates :total, presence: true, numericality: true
  validates :subtotal, presence: true, numericality: true
  validates :tax, presence: true, numericality: true

  before_validation :generate_year, unless: :year?
  before_validation :generate_receipt_id, unless: :receipt_id?

  before_save :calculate_totals, on: :create
  after_create :store_all_on_s3_async, unless: :skip_s3

  def self.years
    distinct(:year).order(year: :desc).pluck(:year)
  end

  def generate_year
    self.year ||= created_at.try(:year) || DateTime.now.year
  end

  def generate_receipt_id
    self.receipt_id ||= "#{reference_number}-#{year}"
  end

  def order_form=(arg_order_form)
    unless arg_order_form
      write_attribute(:order_form, nil)
      write_attribute(:order_form_date, nil)
      return
    end

    if arg_order_form.is_a?(OrderForm)
      write_attribute(:order_form, arg_order_form.to_s)
      write_attribute(:order_form_date, arg_order_form.issued_at)
      return order_form
    end

    super
  end

  def file_path(extension, prefix = '')
    "#{type.downcase.pluralize}/#{year}/#{prefix}#{receipt_id}.#{extension}"
  end

  def pdf
    pdf_generator = PdfGenerator.new
    pdf_generator.convert_url("http://www.vzgojiteljica.si/admin/#{type.downcase.pluralize}/#{to_param}/print")
  end

  def pdf_idempotent
    return pdf_url if pdf_stored?
    store_pdf
    pdf_url
  end

  def pdf_path
    file_path('pdf')
  end

  def store_all_on_s3_async
    ReceiptS3StoreWorker.perform_async(id)
  end

  def store_all_on_s3
    store_pdf
  end

  def store_to_s3(path, data)
    s3_connection.directories.new(key: AWS_S3['bucket']).files.create(
      key: path,
      body: data,
      public: false
    )
  end

  def exists_on_s3?(path)
    !!s3_connection.directories.new(key: AWS_S3['bucket']).files.head(path)
  end

  def pdf_exists_on_s3?
    exists_on_s3?(pdf_path)
  end

  def store_pdf
    store_to_s3(pdf_path, pdf)
    self.pdf_stored = true
    save
    pdf_path
  end

  def s3_url(path)
    s3_connection.directories.new(key: AWS_S3['bucket']).files.new(key: path).url(1.hour.from_now)
  end

  def pdf_url
    s3_url(pdf_path)
  end

  def s3_connection
    @s3_connection ||= Fog::Storage.new(provider: 'AWS',
                                        aws_access_key_id: AWS_S3['access_key_id'],
                                        aws_secret_access_key: AWS_S3['secret_access_key'])
  end

  def calculate_totals
    self.tax_percent = TAX_PERCENT
    self.tax         = line_items.to_a.sum(&:tax)
    self.subtotal    = line_items.to_a.sum(&:subtotal)
    self.total       = line_items.to_a.sum(&:total)
  end

  def to_s
    "Receipt #{receipt_id}"
  end

  def to_param
    receipt_id
  end
end
