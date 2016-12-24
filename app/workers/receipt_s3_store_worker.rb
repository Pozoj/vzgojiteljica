# frozen_string_literal: true
class ReceiptS3StoreWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(receipt_id)
    return if Rails.env.test?
    return unless invoice = Receipt.find(receipt_id)
    receipt.store_all_on_s3
  end
end
