class ReceiptWizardWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(wizard_params)
    @receipt_wizard = ReceiptWizard.new(wizard_params)
    @collection = if wizard_params[:include_yearly] == "1"
      receipts = @receipt_wizard.create_receipts
    else
      receipts = @receipt_wizard.create_per_issue_receipts
    end

    # Queue S3 uploads.
    ReceiptsS3StoreWorker.perform_async(receipts.compact.uniq.map(&:id))
  end
end
