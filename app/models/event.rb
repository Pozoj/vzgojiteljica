class Event < ActiveRecord::Base
  belongs_to :eventable, polymorphic: true
  belongs_to :user

  VALID_EVENTS = %w{
    customer_order_form_email_sent
    invoice_sent invoice_due_sent invoice_send_error
    order_form_processed
    statement_entry_invalid
  }

  validates :event, presence: true, inclusion: { in: VALID_EVENTS }
end
