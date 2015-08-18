class InvoicesWizardWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 1

  def perform(wizard_params)
    @invoice_wizard = InvoiceWizard.new(wizard_params)
    @collection = if wizard_params[:include_yearly] == "1"
      invoices = @invoice_wizard.create_invoices
    else
      invoices = @invoice_wizard.create_per_issue_invoices
    end

    # Queue S3 uploads.
    InvoicesS3StoreWorker.perform_async(invoices.compact.uniq.map(&:id))
  end
end