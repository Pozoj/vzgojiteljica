# Vzgojiteljica.si

* Rails 4
* Ruby 2
* HTML 5
* CSS 3

Rails app and site design by [Miha Rebernik](http://github.com/mihar) and [Patricija Valentinuzzi](http://github.com/particija).

# TO DO

Models:

USER
  [Entity]

ENTITY
  - Title (company)
  - Name  (person)
  - Address
  - ZIP
  - Post
  - Phone
  - Email
  - VAT ID
  - Notes

CUSTOMER < Entity
  [Subscriptions]

SUBSCRIPTION
  [Customer]
  [Subscribers]
  - Start
  - End
  - Notes
  - Discount
  - Plan

SUBSCRIBER < Entity
  [Subscription]
  - Quantity

PLAN
  - Name
  - Price
  - Billing frequency (Per year)

ISSUE
  - Name
  - Price
  - Issues per year
  [Product Type]

PRODUCT TYPES
  - Name

INVOICE
  [Customer]
  - Due at
  - Paid
  - Reference #
  - Subtotal
  - Tax
  - Total
