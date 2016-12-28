# frozen_string_literal: true
module DuplicateFinder
  def find_duplicates
    duplicates = {}
    all_customers = Customer.all.order(:id)
    all_customers.each do |customer|
      duplicates[customer.to_s] ||= Set.new
      duplicates[customer.name] ||= Set.new
      duplicates[customer.title] ||= Set.new
    end

    all_customers.each do |customer|
      puts "* Looking at #{customer}"

      duplicates[customer.to_s].add(customer)
      duplicates[customer.name].add(customer) if customer.name?
      duplicates[customer.title].add(customer) if customer.title?

      # Go Levenshtein on them.
      duplicates.keys.each do |customer_key|
        if Levenshtein.compute(customer_key, customer.to_s) < 5
          duplicates[customer.to_s].add(customer)
        end
        if customer.name? && Levenshtein.compute(customer_key, customer.name) < 5
          duplicates[customer.name].add(customer)
        end
        if customer.title? && Levenshtein.compute(customer_key, customer.title) < 5
          duplicates[customer.title].add(customer)
        end
      end
    end

    duplicates = duplicates.reject { |_k, v| v.length < 2 }
  end


end
