class InvoicesDueToCustomerEmailerWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform
    return unless ENV["DUE_INVOICES_EMAILER_ENABLED"] == 'true'

    # Only send on Tuesday's, after we can process Monday's payments
    return unless Date.today.tuesday?

    Invoice.unpaid.due.where(year: Date.today.year).order(receipt_id: :asc).each do |invoice|
      # Skip if invoice is not yet due for a week.
      next if invoice.due_at > 1.week.ago

      last_due_email_sent = invoice.events.where(event: :invoice_due_sent).order(created_at: :desc).first

      # Skip if invoice due was emailed in the past week.
      next if last_due_email_sent && last_due_email_sent.created_at > 1.week.ago

      # Check the user has a billing email set.
      next unless invoice.customer.billing_email.present?

      # Now send the due email.
      Mailer.delay.invoice_due_to_customer(invoice.id)

      puts "Sending due email to #{invoice.customer}"
    end
  end
end
