# frozen_string_literal: true
class InvoicesDueToCustomerEmailerWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    # Only send on Tuesday's, after we can process Monday's payments
    return unless Date.today.tuesday?

    customers = {}
    Invoice.unpaid.due.where(year: Date.today.year).order(receipt_id: :asc).each do |invoice|
      # Skip if invoice is not yet due for a week.
      next if invoice.due_at > 1.week.ago

      last_due_email_sent = invoice.events.where(event: :invoice_due_sent).order(created_at: :desc).first

      # Skip if invoice due was emailed in the past week.
      next if last_due_email_sent && last_due_email_sent.created_at > 1.week.ago

      # Check the user has a billing email set.
      next unless invoice.customer.billing_email.present?

      customers[invoice.customer.id] ||= []
      customers[invoice.customer.id] << invoice.id
    end

    # Now loop through the customers to group them together
    customers.each do |customer_id, invoice_ids|
      customer = Customer.find(customer_id)

      if customer.flag?(:do_not_send_due_emails)
        puts "Skipping due email to #{customer} ..."
        next
      end

      puts "Sending due email to #{customer} (#{customer.billing_email}) for #{invoice_ids.length} invoice(s)"

      unless ENV['DUE_INVOICES_EMAILER_ENABLED'] == 'true' || Rails.env.development?
        next
      end

      # Now send the due email.
      if invoice_ids.length == 1
        Mailer.delay.invoice_due_to_customer(invoice_ids.first)
      elsif invoice_ids.length > 1
        Mailer.delay.invoices_due_to_customer(customer_id, invoice_ids)
      end
    end
  end
end
