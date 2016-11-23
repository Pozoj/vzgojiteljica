class InvoiceEmailerWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(invoice_id)
    return unless invoice = Invoice.find_by(id: invoice_id)
    Mailer.delay.invoice_to_customer(invoice.id)
  end
end

