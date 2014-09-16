require 'pry'
class Legacy < ActiveRecord::Base; end

Entity.delete_all
Subscription.delete_all
Plan.delete_all

plan_annual = Plan.create name: "Vzgojiteljica 2014 - Letna naročnina", billing_frequency: 1, price: 6
plan_per_issue = Plan.create name: "Vzgojiteljica 2014 - Posamezna revija", billing_frequency: 6, price: 1
plan_free = Plan.create name: "Vzgojiteljica 2014 - Brezplačno", billing_frequency: 6, price: 0

def levenshtein(s, t)
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

def titleize s
  return if s.strip == '.'
  s.mb_chars.strip.normalize.titleize.gsub('Os ', "OŠ ").gsub('Oš ', 'OŠ ').gsub('Mo ', 'MO ').gsub(/\sulica/i, ' ulica').
    gsub(/\scesta/i, ' cesta').gsub(/\strg/i, ' trg').gsub(/\svas/i, ' vas').gsub('D.O.O.', 'd.o.o.').gsub('S.P.', 's.p.').
    gsub('D. O. O.', 'd.o.o.').gsub('D.N.O.', 'd.n.o.').gsub('Pri ', 'pri ').gsub(' Na ', ' na ').
    gsub('P.O.', 'p.o.').gsub('Um ', 'UM ').gsub(' Um', ' UM').gsub(' Ul', ' UL').gsub('Vve', 'VVE').
    gsub(' V ', ' v ').gsub(' Za ', ' za ').gsub(' In ', ' in ').gsub(' Iv. ', ' IV. ').gsub(' Oe ', ' OE ').gsub(' Vi. ', ' VI. ').
    gsub(' Ob ', ' ob ').gsub(' Ii. ', ' II. ').gsub('Vvz', 'VVZ').gsub('Viz', 'VIZ')
end

def parse_customer r
  c = Customer.new
  c.title = titleize r.customer_title
  c.address = titleize r.customer_address
  c.post_id = r.customer_post_id
  c.phone = r.customer_phone1 or r.customer_phone3
  c.email = r.customer_email.downcase
  c.vat_id = r.customer_vat_id.upcase
  c.vat_exempt = (r.customer_vat_exempt == 'D') ? true : false
  c.save!

  if r.customer_contact_person.present?
    c.create_contact_person name: titleize(r.customer_contact_person)
  end
  if r.customer_payment_person.present?
    c.create_billing_person name: titleize(r.customer_payment_person)
  end
  if r.customer_notes.present?
    c.remarks.create remark: r.customer_notes
  end
  c
end

def parse_subscriber r
  s = Subscriber.new
  s.title = titleize r.subcriber_title
  s.address = titleize r.subscriber_address
  s.post_id = r.subscriber_post_id
  s.quantity = r.subscription_quantity
  s.save!

  if r.subscriber_contact_person.present?
    if r.subscriber_contact_person.match(/.+\@.+\..+/i)
      s.email = r.subscriber_contact_person.downcase.strip
      s.save
    elsif r.subscriber_contact_person.match(/\d{2,3}[\/\-]{1}.*/i)
      s.phone = r.subscriber_contact_person.strip
      s.save
    else
      s.create_contact_person name: titleize(r.subscriber_contact_person)
    end
  end

  if r.subscriber_notes.present?
    s.remarks.create remark: r.subscriber_notes
  end

  puts "[SUBSCRIBER] #{s.inspect}"
  s
end


Legacy.all.reject { |r| r.customer_id == 16 }.group_by { |r| r.customer_id }.each do |cid, r|
  # CUSTOMER
  c = parse_customer r.first
  puts "[CUSTOMER] #{c.inspect}"

  s = Subscription.new
  r1 = r.first
  s.start = r1.subscription_start
  s.end = r1.subscription_end

  if r1.customer_id_again == 0
    s.plan = plan_free
  elsif r1.customer_id_again == 1
    s.plan = plan_annual
  elsif r1.customer_id_again == 6
    s.plan = plan_per_issue
  else
    puts "PLAN ERROR #{r1.customer_id_again}"
  end

  s.save!

  s.remarks.create remark: "LAST CHANGE: #{r1.subscription_change}\nLAST EVENT: #{r1.subscription_last_event}\nSTATUS: #{r1.subscription_status}"

  puts "[SUBSCRIPTION] #{s.inspect}"

  r.each { |subscriber| s.subscribers << parse_subscriber(subscriber) }

  c.subscriptions << s
end

Legacy.where(customer_id: 16).each do |r|
  # CUSTOMER
  c = Customer.new
  c.title = titleize r.subcriber_title
  c.address = titleize r.subscriber_address
  c.post_id = r.subscriber_post_id
  c.phone = r.customer_phone1 or r.customer_phone3
  c.email = r.customer_email.downcase
  c.vat_id = r.customer_vat_id.upcase
  c.vat_exempt = true
  c.save!

  if r.customer_contact_person.present?
    c.create_contact_person name: titleize(r.customer_contact_person)
  end
  if r.customer_payment_person.present?
    c.create_billing_person name: titleize(r.customer_payment_person)
  end
  if r.customer_notes.present?
    c.remarks.create remark: r.customer_notes
  end
  c

  puts "[CUSTOMER] #{c.inspect}"

  s = Subscription.new
  s.start = r.subscription_start
  s.end = r.subscription_end


  if r.subscriber_contact_person.present? and r.subscriber_contact_person.match(/zastonj/i)
    s.plan = plan_free
  elsif r.customer_id_again == 0
    s.plan = plan_free
  elsif r.customer_id_again == 1
    s.plan = plan_annual
  elsif r.customer_id_again == 6
    s.plan = plan_per_issue
  else
    puts "PLAN ERROR #{r.customer_id_again}"
  end

  s.save!

  s.remarks.create remark: "LAST CHANGE: #{r.subscription_change}\nLAST EVENT: #{r.subscription_last_event}\nSTATUS: #{r.subscription_status}"

  puts "[SUBSCRIPTION] #{s.inspect}"

  su = Subscriber.new
  su.title = titleize r.subcriber_title
  su.address = titleize r.subscriber_address
  su.post_id = r.subscriber_post_id
  su.quantity = r.subscription_quantity
  su.save!

  if r.subscriber_contact_person.present?
    if r.subscriber_contact_person.match(/zastonj/i)
      su.remarks.create remark: 'Zastonj'
    elsif r.subscriber_contact_person.match(/.+\@.+\..+/i)
      c.email = r.subscriber_contact_person.downcase.strip
      c.save
    elsif r.subscriber_contact_person.match(/\d{2,3}[\/\-]{1}.*/i)
      c.phone = r.subscriber_contact_person.strip
      c.save
    else
      su.remarks.create remark: r.subscriber_contact_person.strip
    end
  end

  if r.subscriber_notes.present?
    su.remarks.create remark: r.subscriber_notes
  end

  puts "[SUBSCRIBER] #{su.inspect}"

  s.subscribers << su
  c.subscriptions << s
end
