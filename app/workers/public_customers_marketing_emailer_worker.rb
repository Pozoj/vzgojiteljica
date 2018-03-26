# frozen_string_literal: true
class PublicCustomersMarketingEmailerWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    Customer.company.each do |customer|
      if customer.subscriptions.any?
        puts "Customer #{customer.id} has subscriptions"
        next
      end

      # if customer.subscriptions.where('end > ?', 2.years.ago).any?
      #   puts "Customer #{customer.id} had subscriptions in the last 2 years"
      #   next
      # end

      unless customer.billing_email
        puts "Customer #{customer.id} has no email to send to"
        next
      end

      if customer.events.where(event: 'customer_marketing_email_sent').any?
        puts "Skipping customer #{customer.id}, already sent"
        next
      end

      # Send email
      if Mailer.customer_marketing(customer.id).deliver_now
        puts "Sent email to customer #{customer.id} #{customer}"
        customer.events.create!(event: 'customer_marketing_email_sent')
      end

      sleep 5
    end
  end
end
