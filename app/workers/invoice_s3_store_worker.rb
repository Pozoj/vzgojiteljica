class InvoiceS3StoreWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 1

  def perform(invoice_id)
    return unless invoice = Invoice.find(invoice_id)
    invoice.store_pdf
    sleep 0.5
    invoice.store_einvoice
    return unless invoice.customer.einvoice?
    invoice.store_eenvelope
  end
end