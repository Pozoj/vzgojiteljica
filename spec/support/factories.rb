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
    name "Letna naročnina"
  end

  factory :subscriber do
    customer
    name "Loram Ipsam"
  end

  factory :customer do
    name "Customar Ipsam"
  end

  factory :order do
    quantity 1
    plan_type 1
    name "Loram Ipsam"
    email "loram@ipsam.com"
    address "8 Buchanan St"
    post_id 1000
  end

  factory :order_form do
    order
    customer
    form_id "Naročilnica #1000"
  end
end
