class Admin::InvoicesController < InheritedResources::Base
  before_filter :authenticate
  layout "admin"

  def index
    @invoice_wizard = InvoiceWizard.new params[:invoice_wizard]
    @invoices = Invoice.order(reference_number: :desc).page params[:page]
  end

  def create
    @invoice_wizard = InvoiceWizard.new params[:invoice_wizard]
    @collection = @invoice_wizard.process!
    redirect_to admin_invoices_path
  end

  def print
    render layout: 'print'
  end

  def print_all
    @invoices = Invoice.where(issue_id: params[:issue_id])
    render layout: 'print'
  end
end
