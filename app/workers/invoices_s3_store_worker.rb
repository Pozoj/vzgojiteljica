class InvoicesS3StoreWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 1

  def perform(invoice_ids)
    invoice_ids.each do |invoice_id|
      next unless invoice = Invoice.find(invoice_id)

      invoice.store_all_on_s3
      sleep 2
    end
  end
end