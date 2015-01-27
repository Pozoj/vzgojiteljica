class Admin::InvoicesController < Admin::AdminController
  def index
    @invoice_wizard = InvoiceWizard.new params[:invoice_wizard]
    @gte = Invoice.select(:reference_number).order(reference_number: :asc).first.try(:reference_number)
    @lte = Invoice.select(:reference_number).order(reference_number: :desc).first.try(:reference_number)

    respond_with collection
  end

  def show
    respond_with resource
  end

  def create
    @invoice_wizard = InvoiceWizard.new params[:invoice_wizard]
    @collection = if params[:invoice_wizard][:include_yearly] == "1"
      @invoice_wizard.create_invoices
    else
      @invoice_wizard.create_per_issue_invoices
    end
    redirect_to admin_invoices_path
  end

  def build_for_subscription
    subscription = Subscription.find(params[:subscription_id])

    wizard = InvoiceWizard.new
    unless subscription.plan.yearly?
      wizard.issue_id = Issue.order(published_at: :desc).first.id
    end
    invoice = wizard.build_invoice_for_subscription subscription
    invoice.save!

    redirect_to admin_invoice_path(invoice)
  end

  def print
    respond_with resource, layout: 'print'
  end

  def print_all
    @invoices = Invoice.all
    if lte = params[:lte]
      @invoices = @invoices.where("reference_number <= #{lte}")
    end
    if gte = params[:gte]
      @invoices = @invoices.where("reference_number >= #{gte}")
    end
    @invoices.order(:reference_number)

    render layout: 'print'
  end

  private

  def collection
    @invoices ||= Invoice.order(reference_number: :desc).page(params[:page])
  end

  def resource
    @invoice = Invoice.find(params[:id])
  end
end
