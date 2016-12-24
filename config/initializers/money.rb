# encoding : utf-8
# frozen_string_literal: true

MoneyRails.configure do |config|
  # To set the default currency
  #
  config.default_currency = :eur

  # Set default money format globally.
  # Default value is nil meaning "ignore this option".
  # Example:
  #
  # config.default_format = {
  #   :no_cents_if_whole => nil,
  #   :symbol => nil,
  #   :sign_before_symbol => nil
  # }
end
