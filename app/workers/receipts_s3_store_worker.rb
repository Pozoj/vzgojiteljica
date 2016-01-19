class ReceiptsS3StoreWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(receipt_ids)
    receipt_ids.each do |receipt_id|
      next unless receipt = Receipt.find(receipt_id)

      receipt.store_all_on_s3
      sleep 2
    end
  end
end
