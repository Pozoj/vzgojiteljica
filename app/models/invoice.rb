class Invoice < ActiveRecord::Base
  include Invoicing

  monetize :subtotal_cents
  monetize :total_cents
  monetize :paid_amount_cents

  belongs_to :customer
  belongs_to :issue
  has_many :remarks, as: :remarkable
  has_many :line_items, dependent: :destroy

  before_save :calculate_totals

  def reference_full
    "#{reference_number}/ REV /#{created_at.strftime("%Y")}"
  end

  def invoice_id
    "SI00#{reference_number}-#{created_at.strftime("%Y")}"
  end

  def match_statement_entry
    query = "%#{invoice_id}%"
    StatementEntry.where(StatementEntry.arel_table[:details].matches(query)).first
  end

  def calculate_totals
    self.tax_percent ||= TAX_PERCENT
    self.tax ||= line_items.to_a.sum(&:tax)
    self.subtotal ||= line_items.to_a.sum(&:subtotal)
    self.total ||= line_items.to_a.sum(&:total)
  end
end