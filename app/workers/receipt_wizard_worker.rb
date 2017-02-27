# frozen_string_literal: true
class ReceiptWizardWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(wizard_params)
    @receipt_wizard = ReceiptWizard.new(wizard_params)

    receipts = if wizard_params["include_yearly"] == '1'
                 @receipt_wizard.create_receipts
               else
                 @receipt_wizard.create_per_issue_receipts
               end

    receipts = receipts.compact.uniq

    # Queue S3 uploads.
    ReceiptsS3StoreWorker.perform_async(receipts.map(&:id))

    # Queue emails.
    receipts.each do |receipt|
      customer = receipt.customer

      next if customer.einvoice?

      unless customer.billing_email.present?
        Scrolls.log(message: 'No customer billing email present!')
        next
      end

      InvoiceEmailerWorker.perform_in(30.minutes, receipt.id)
    end
  end
end
