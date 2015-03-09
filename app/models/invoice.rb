class Invoice < ActiveRecord::Base
  include Invoicing

  monetize :subtotal_cents
  monetize :total_cents
  monetize :paid_amount_cents
  monetize :tax_cents

  belongs_to :customer
  belongs_to :issue
  has_many :remarks, as: :remarkable
  has_many :line_items, dependent: :destroy

  validates_presence_of :customer
  validates_presence_of :issue
  validates_presence_of :year
  validates_numericality_of :year, only_integer: true
  validates_presence_of :invoice_id
  validates_uniqueness_of :invoice_id
  validates_presence_of :payment_id
  validates_uniqueness_of :payment_id
  validates_presence_of :total
  validates_presence_of :subtotal
  validates_presence_of :tax

  before_validation :generate_year, unless: :year?
  before_validation :generate_invoice_id, unless: :invoice_id?
  before_validation :generate_payment_id, unless: :payment_id?

  before_save :calculate_totals

  scope :unpaid, -> { where(paid_at: nil) }

  def self.match_to_statements!
    Invoice.unpaid.each do |i|
      next unless i.match_statement_entry
      next unless i.match_statement_entry.amount == i.total
      i.paid_by! i.match_statement_entry
    end
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
    self.year ||= created_at.year
  end

  def generate_invoice_id
    self.invoice_id ||= "#{reference_number}-#{year}"
  end

  def generate_payment_id
    return unless customer_id?
    self.payment_id ||= "#{customer_id}-#{invoice_id}"
  end

  def payment_id_full
    "SI 00 #{payment_id}"
  end

  def match_statement_entry
    query = "%SI00#{reference_number}%"
    @statement_entry ||= StatementEntry.where(StatementEntry.arel_table[:details].matches(query)).first
  end

  def calculate_totals
    self.tax_percent ||= TAX_PERCENT
    self.tax ||= line_items.to_a.sum(&:tax)
    self.subtotal ||= line_items.to_a.sum(&:subtotal)
    self.total ||= line_items.to_a.sum(&:total)
  end
end
