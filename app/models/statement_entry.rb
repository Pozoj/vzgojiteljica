class StatementEntry < ActiveRecord::Base
  belongs_to :bank_statement
  validates_presence_of :account_holder, :account_number, :amount, :date, :reference, :bank_statement

  monetize :amount_cents

  def matches
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
end
