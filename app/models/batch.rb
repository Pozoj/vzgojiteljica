# frozen_string_literal: true
class Batch < ActiveRecord::Base
  has_many :plans
  has_many :issues

  monetize :price_cents
end
