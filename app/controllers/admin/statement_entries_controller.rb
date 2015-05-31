class Admin::StatementEntriesController < Admin::AdminController
  def show
    respond_with resource
  end

  def match
    invoice = Invoice.find_by(invoice_id: params[:invoice_id])
    resource.match_to_invoice!(invoice)
    respond_with resource, location: -> { admin_invoice_path(invoice) }
  end

  private

  def resource
    @statement_entry ||= StatementEntry.find(params[:id])
  end
end
