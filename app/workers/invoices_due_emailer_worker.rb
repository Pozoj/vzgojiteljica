class InvoicesDueEmailerWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform
    return unless Date.today.sunday?
    AdminMailer.invoices_due.deliver_now
  end
end