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
        if levenshtein(customer_key, customer.to_s) < 5
          duplicates[customer.to_s].add(customer)
        end
        if customer.name? && levenshtein(customer_key, customer.name) < 5
          duplicates[customer.name].add(customer)
        end
        if customer.title? && levenshtein(customer_key, customer.title) < 5
          duplicates[customer.title].add(customer)
        end
      end
    end

    duplicates = duplicates.reject { |k, v| v.length < 2 }
  end

  def levenshtein(s, t)
    return 0 unless s
    return 0 unless t
    s = s.downcase
    t = t.downcase
    m = s.length
    n = t.length
    return m if n == 0
    return n if m == 0
    d = Array.new(m+1) {Array.new(n+1)}

    (0..m).each {|i| d[i][0] = i}
    (0..n).each {|j| d[0][j] = j}
    (1..n).each do |j|
      (1..m).each do |i|
        d[i][j] = if s[i-1] == t[j-1]  # adjust index into string
                    d[i-1][j-1]       # no operation required
                  else
                    [ d[i-1][j]+1,    # deletion
                      d[i][j-1]+1,    # insertion
                      d[i-1][j-1]+1,  # substitution
                    ].min
                  end
      end
    end
    d[m][n]
  end
end
