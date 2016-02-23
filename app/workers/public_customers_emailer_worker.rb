class PublicCustomersEmailerWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform
    Customer.where(einvoice: true).each do |customer|
      unless customer.billing_email
        puts "Customer #{customer.id} has no email to send to"
        next
      end

      if customer.events.where(event: 'customer_order_form_email_sent').any?
        puts "Skipping customer #{customer.id}, already sent"
        next
      end

      if customer.order_forms.where(year: Date.today.year).any?
        puts "Customer #{customer.id} already submitted order form"
        next
      end

      # Send email
      if Mailer.customer_order_form_needed(customer.id).deliver_now
        puts "Sent email to customer #{customer.id}"
        customer.events.create!(event: 'customer_order_form_email_sent')
      end

      sleep 5
    end
  end
end