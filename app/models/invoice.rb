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

  before_save :calculate_totals

  scope :unpaid, -> { where(paid_at: nil) }

  def self.match_to_statements!
    Invoice.unpaid.each do |i|
      next unless i.match_statement_entry
      next unless i.match_statement_entry.amount == total
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

  def reference_full
    "#{reference_number}/ REV /#{created_at.strftime("%Y")}"
  end

  def invoice_id
    "SI00#{reference_number}-#{created_at.strftime("%Y")}"
  end

  def match_statement_entry
    query = "%#{invoice_id}%"
    @statement_entry ||= StatementEntry.where(StatementEntry.arel_table[:details].matches(query)).first
  end

  def calculate_totals
    self.tax_percent ||= TAX_PERCENT
    self.tax ||= line_items.to_a.sum(&:tax)
    self.subtotal ||= line_items.to_a.sum(&:subtotal)
    self.total ||= line_items.to_a.sum(&:total)
  end
end