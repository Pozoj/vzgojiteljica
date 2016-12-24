# frozen_string_literal: true
class Filter
  include ActiveModel::Model
  attr_accessor :type, :entity_type, :einvoice, :title, :name, :address, :vat_id, :global
end
