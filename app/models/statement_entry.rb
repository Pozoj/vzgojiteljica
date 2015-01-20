class StatementEntry < ActiveRecord::Base
  belongs_to :bank_statement
  validates_presence_of :account_holder, :account_number, :amount, :date, :details, :reference, :bank_statement

  monetize :amount_cents
end
