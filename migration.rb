require 'pry'
class Legacy < ActiveRecord::Base; end

Entity.delete_all
Subscription.delete_all
Plan.delete_all

PLAN_ANNUAL = Plan.create name: "Vzgojiteljica 2014 - Letna naročnina", billing_frequency: 1, price: 34.8
PLAN_PER_ISSUE = Plan.create name: "Vzgojiteljica 2014 - Posamezna revija", billing_frequency: 6, price: 5.3
PLAN_FREE = Plan.create name: "Vzgojiteljica 2014 - Brezplačno", billing_frequency: 6, price: 0

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

def parse_subscription r1
  s = Subscription.new
  s.start = fix_and_parse_date r1.subscription_start_before_type_cast
  s.end = fix_and_parse_date r1.subscription_end_before_type_cast

  if r1.subscriber_contact_person.present? && r1.subscriber_contact_person.match(/zastonj/i)
    s.plan = PLAN_FREE
  elsif r1.customer_id_again == 0
    s.plan = PLAN_FREE
  elsif r1.customer_id_again == 1
    s.plan = PLAN_ANNUAL
  elsif r1.customer_id_again == 6
    s.plan = PLAN_PER_ISSUE
  else
    puts "PLAN ERROR #{r1.customer_id_again}"
  end

  s.save!

  s.remarks.create remark: "LAST CHANGE: #{r1.subscription_change}\nPREV QUANTITY: #{r1.subscription_last_event}\nSTATUS: #{r1.subscription_status}"

  puts "[SUBSCRIPTION] #{s.inspect}"

  s
end

def parse_subscriber r, true_customer = false
  s = Subscriber.new
  s.title = titleize r.subcriber_title
  s.address = titleize r.subscriber_address
  s.post_id = r.subscriber_post_id
  s.quantity = r.subscription_last_event
  s.save!

  s.subscriptions << parse_subscription(r)

  if r.subscriber_contact_person.present?
    if r.subscriber_contact_person.match(/zastonj/i)
      s.remarks.create remark: 'Zastonj'
    elsif r.subscriber_contact_person.match(/.+\@.+\..+/i)
      s.email = r.subscriber_contact_person.downcase.strip
      s.save
    elsif r.subscriber_contact_person.match(/\d{2,3}[\/\-]{1}.*/i)
      s.phone = r.subscriber_contact_person.strip
      s.save
    else
      if true_customer
        s.create_contact_person name: titleize(r.subscriber_contact_person)
      else
        s.remarks.create remark: r.subscriber_contact_person.strip
      end
    end
  end

  if r.subscriber_notes.present?
    s.remarks.create remark: r.subscriber_notes
  end

  puts "[SUBSCRIBER] #{s.inspect}"
  s
end

def fix_and_parse_date date_string
  return unless date_string
  return unless matching = date_string.match(/(\d{1,2})\/(\d{1,2})\/(\d{4})/)
  fixed_date = date_string.gsub("#{matching[1]}/#{matching[2]}/#{matching[3]}", "#{matching[2]}/#{matching[1]}/#{matching[3]}")
  Date.parse fixed_date
end

Legacy.all.reject { |r| r.customer_id == 16 }.group_by { |r| r.customer_id }.each do |cid, r|
  # CUSTOMER
  c = parse_customer r.first
  puts "[CUSTOMER] #{c.inspect}"

  r.each { |subscriber| c.subscribers << parse_subscriber(subscriber) }
end

Legacy.where(customer_id: 16).each do |r|
  # CUSTOMER
  c = parse_customer r
  c.title = titleize r.subcriber_title
  c.address = titleize r.subscriber_address
  c.post_id = r.subscriber_post_id
  c.vat_exempt = true
  c.save!

  su = parse_subscriber r, true

  c.email = su.email if su.email
  c.phone = su.phone if su.phone

  c.subscribers << su
end
