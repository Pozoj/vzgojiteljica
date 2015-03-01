class Admin::StatementEntriesController < Admin::AdminController
  def show
    respond_with resource
  end

  def match
    invoice = Invoice.find(params[:invoice_id])
    invoice.paid_by!(resource)
    respond_with resource, location: -> { admin_invoice_path(invoice) }
  end

  private

  def resource
    @statement_entry ||= StatementEntry.find(params[:id])
  end
end