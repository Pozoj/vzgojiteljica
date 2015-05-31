class Admin::InvoicesController < Admin::AdminController
  skip_before_filter :authenticate, only: [:print]
  
  def index
    @invoice_wizard = InvoiceWizard.new params[:invoice_wizard]
    @gte = Invoice.select(:reference_number).order(reference_number: :asc).first.try(:reference_number)
    @lte = Invoice.select(:reference_number).order(reference_number: :desc).first.try(:reference_number)

    @years = Invoice.years
    @all_invoices = Invoice.select(:id, :invoice_id).order(year: :desc, reference_number: :desc).map { |i| [i.invoice_id, i.id] }

    @invoices = collection
    if params[:year]
      @invoices = @invoices.where(year: params[:year])
    elsif params[:all]
    else
      @invoices = @invoices.where(year: DateTime.now.year)
    end
    respond_with collection
  end

  def unpaid
    @years = Invoice.years
    @invoices = collection.unpaid
    if params[:year]
      @invoices = @invoices.where(year: params[:year])
    elsif params[:all]
    else
      @invoices = @invoices.where(year: DateTime.now.year)
    end
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

  def pdf
    redirect_to resource.pdf_idempotent
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

  def einvoice
    @einvoice = EInvoice.new(invoice: resource).generate
    respond_to do |format|
      format.xml { render layout: 'einvoice' }
    end
  end

  def eenvelope
    @eenvelope = EEnvelope.new(invoice: resource).generate
    respond_to do |format|
      format.xml { render layout: 'eenvelope' }
    end
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
    @invoices = @invoices.order(:reference_number).reject { |i| i.customer.einvoice? }

    render layout: 'print'
  end

  private

  def collection
    @invoices ||= Invoice.order(year: :desc, reference_number: :desc).page(params[:page]).per(50)
  end

  def resource
    @invoice = Invoice.find_by(invoice_id: params[:id])
  end
end
