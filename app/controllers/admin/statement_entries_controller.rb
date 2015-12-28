class Admin::StatementEntriesController < Admin::AdminController
  def show
    @unpaid_invoices = Invoice.unpaid.select(:id, :invoice_id).order(year: :desc, reference_number: :desc).map { |i| [i.invoice_id, i.invoice_id] }
    respond_with resource
  end

  def match
    invoice = Invoice.find_by(invoice_id: params[:invoice_id])
    resource.match_to_invoice!(invoice)
    respond_with resource, location: -> { admin_invoice_path(invoice) }
  end

  private

  def resource
    return unless params[:id]
    @statement_entry ||= StatementEntry.find(params[:id])
  end

  def set_page_title
    @page_title = 'Postavke izpiska'
  end
end
