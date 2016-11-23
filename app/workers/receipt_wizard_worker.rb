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

    receipts = receipts.compact.uniq

    # Queue S3 uploads.
    ReceiptsS3StoreWorker.perform_async(receipts.map(&:id))

    # Queue emails.
    receipts.each do |receipt|
      customer = receipt.customer

      next if customer.einvoice?

      unless customer.billing_email.present?
        Scrolls.log(message: "No customer billing email present!")
        next
      end

      Mailer.delay.invoice_to_customer(receipt.id)
    end
  end
end
