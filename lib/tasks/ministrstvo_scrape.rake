# frozen_string_literal: true

# require 'vcr'

# VCR.configure do |config|
#   config.cassette_library_dir = "vcr_cassettes"
#   config.hook_into :fakeweb
# end

namespace :ministrstvo do
  task scrape: :environment do
    data = nil
    found = 0
    not_found = 0

    # VCR.use_cassette("ministrstvo") do
    data = Scrapers::MinistrstvoScraper.new.parse
    # end

    log "[MinistrstvoScraper] Processing #{data.length} records"

    data.each do |subscriber|
      entity = Customer.find_by(vat_id: subscriber.vat_id)
      if entity
        # update_subscriber(subscriber)
        found += 1
      else
        create_subscriber(subscriber)
        not_found += 1
      end
    end

    log "Total: #{data.length}, updated: #{found}, created: #{not_found}"
  end
end

def log(msg)
  puts "[MinistrstvoScraper] #{msg}"
end

def create_subscriber(subscriber)
  Entity.transaction do
    customer_entity = Customer.new
    subscriber_entity = Subscriber.new

    customer_entity.title = subscriber.primary.title
    customer_entity.address = subscriber.primary.address
    customer_entity.post_id = subscriber.primary.post_id
    customer_entity.phone = subscriber.primary.phone
    customer_entity.email = subscriber.primary.email
    customer_entity.vat_id = subscriber.primary.vat_id
    customer_entity.account_number = subscriber.primary.account_number || subscriber.account_number
    customer_entity.einvoice = subscriber.legal_status == :public
    customer_entity.registration_number = subscriber.primary.registration_number
    customer_entity.entity_type = 1

    if subscriber.legal_status == :public
      bank = Bank.find_by(bic: 'BSLJSI2X')
      customer_entity.bank_id = bank.id
    end

    customer_entity.save!

    subscriber_entity.title = subscriber.title
    subscriber_entity.address = subscriber.address
    subscriber_entity.post_id = subscriber.post_id
    subscriber_entity.customer = customer_entity

    subscriber_entity.save!
  end
end
