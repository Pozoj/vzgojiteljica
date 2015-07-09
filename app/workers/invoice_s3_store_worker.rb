class InvoiceS3StoreWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 1

  def perform(invoice_id)
    return unless invoice = Invoice.find(invoice_id)
    invoice.store_all_on_s3
  end
end