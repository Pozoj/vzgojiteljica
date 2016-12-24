# frozen_string_literal: true
FactoryGirl.define do
  factory :subscription do
    plan
    subscriber
    start { 1.year.ago }
    self.end { 1.year.from_now }
    quantity 1

    trait :inactive do
      self.end { 1.month.ago }
    end

    trait :without_ending do
      self.end nil
    end
  end

  factory :plan do
    billing_frequency 1
    name 'Letna naročnina'
    price_cents 500

    trait :free do
      price_cents 0
    end
  end

  factory :subscriber do
    customer
    name 'Loram Ipsam'
  end

  factory :customer do
    name 'Customar Ipsam'
  end

  factory :order do
    quantity 1
    plan_type 1
    name 'Loram Ipsam'
    email 'loram@ipsam.com'
    address '8 Buchanan St'
    post_id 1000
  end

  factory :order_form do
    order
    customer
    form_id 'Naročilnica #1000'
  end

  factory :receipt do
    customer
    reference_number 1
    type 'Invoice'
    total 10
    subtotal 9
    tax 1
  end

  factory :invoice, parent: :receipt, class: 'Invoice'
  factory :offer, parent: :receipt, class: 'Offer'
end
