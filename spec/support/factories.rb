FactoryGirl.define do
  factory :subscription do
    plan
    subscriber
    start { 1.year.ago }
    self.end { 1.year.from_now }
    quantity 1
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
end
