class StatementEntry < ActiveRecord::Base
  belongs_to :bank_statement
  belongs_to :invoice

  validates_presence_of :account_holder, :account_number, :amount, :date, :reference, :bank_reference, :bank_statement
  validates_uniqueness_of :bank_reference

  monetize :amount_cents

  after_save :find_and_match_to_invoice, unless: :invoice

  scope :matched, -> { where(matched: true) }
  scope :unmatched, -> { where(matched: false) }

  def reference_parsed
    reference.strip.match(/^((\d{1,4})\-)?((\d{1,4})\-)(2014|2015|2016)$/)
  end

  def exact_match
    query = Invoice.arel_table[:payment_id].eq(reference.strip)
    query = query.or(Invoice.arel_table[:invoice_id].eq(reference.strip))
    invoices = Invoice.where(query)
    return unless invoices.length == 1
    return unless invoices.first.total == amount
    invoices.first
  end

  def matches
    if matched_invoice = exact_match
      return [matched_invoice]
    end

    name_title_matches = account_holder.split("\n")

    Invoice.unpaid.reject do |invoice|
      customer = invoice.customer
      reject = true

      # Name and title match.
      name_title_matches.compact.each do |name_title_match|
        if customer.name =~ Regexp.new(name_title_match.strip, 'gi')
          reject = false
        elsif customer.title =~ Regexp.new(name_title_match.strip, 'gi')
          reject = false
        elsif customer.address =~ Regexp.new(name_title_match.strip, 'gi')
          reject = false
        end
      end

      # Account number match.
      if customer.account_number =~ Regexp.new(account_number)
        reject = false
      elsif details =~ Regexp.new(invoice.reference_number.to_s, 'gi')
        reject = false
      end

      reject
    end
  end

  def match_to_invoice!(matched_invoice)
    self.invoice = matched_invoice
    self.matched = true
    matched_invoice.statement_entries << self
    matched_invoice.paid_at = self.date
    matched_invoice.paid_amount = self.amount
    matched_invoice.bank_data = self.details
    matched_invoice.bank_reference = self.bank_reference
    matched_invoice.save
    save
  end

  protected

  def find_and_match_to_invoice
    return if invoice
    return unless matched_invoice = exact_match
    match_to_invoice!(matched_invoice)
  end
end
