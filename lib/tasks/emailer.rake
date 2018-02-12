# frozen_string_literal: true

namespace :emailer do
  task :renewal_email, [:real] => :environment do |t, args|
    real = args[:real] == 'true'
    year = Date.today.year
    puts "Processing customer order forms for #{year}"
    puts "REAL RUN" if real

    Customer.active_and_paid.each do |customer|
      next if customer.order_forms.where(year: year).any?

      puts "Customer ##{customer.id} - #{customer} missing order form for #{year}"

      next unless real

      Mailer.customer_order_form_needed(customer.id)
    end
  end
end
