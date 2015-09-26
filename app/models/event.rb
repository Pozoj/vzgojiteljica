class Event < ActiveRecord::Base
  belongs_to :eventable, polymorphic: true
  belongs_to :user

  VALID_EVENTS = %w{
    invoice_sent invoice_due_sent invoice_send_error
    order_processed
  }

  validates :event, presence: true, inclusion: { in: VALID_EVENTS }
end