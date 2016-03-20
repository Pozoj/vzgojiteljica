class Admin::InvoicesController < Admin::ReceiptsController
  def index
    @years = Invoice.years
    @year_now = DateTime.now.year
    @all_invoices = Invoice.select(:id, :receipt_id).order(year: :desc, reference_number: :desc).map { |i| [i.receipt_id, i.receipt_id] }

    @invoices = collection
    if params[:filter_year]
      @invoices = @invoices.where(year: params[:filter_year])
    elsif params[:filter_year_all]
    else
      @invoices = @invoices.where(year: @year_now)
    end
    respond_with collection
  end

  def unpaid
    @years = Invoice.years
    @invoices = collection.unpaid.unreversed
    if params[:year]
      @invoices = @invoices.where(year: params[:year])
    elsif params[:all]
    else
      @invoices = @invoices.where(year: DateTime.now.year)
    end
    respond_with collection
  end

  def due
    @years = Invoice.years
    @invoices = collection.due.unpaid.unreversed
    if params[:year]
      @invoices = @invoices.where(year: params[:year])
    elsif params[:all]
    else
      @invoices = @invoices.where(year: DateTime.now.year)
    end
    respond_with collection
  end

  def reversed
    @years = Invoice.years
    @invoices = collection.reversed
    if params[:year]
      @invoices = @invoices.where(year: params[:year])
    elsif params[:all]
    else
      @invoices = @invoices.where(year: DateTime.now.year)
    end
    respond_with collection
  end

  def reverse
    @invoice = resource
    @invoice.reversed_at = Time.now
    @invoice.reverse_reason = params.require(:invoice).delete(:reverse_reason)
    @invoice.save

    respond_with resource, location: -> { admin_invoice_path(@invoice) }
  end

  def wizard
    @wizard = ReceiptWizard.new(wizard_params)
    @last = Invoice.select(:reference_number).
            where(year: Date.today.year).
            order(year: :desc, reference_number: :desc).
            first.try(:reference_number) || 0
  end

  def print_wizard
    @gte = Invoice.select(:reference_number).order(:year, :reference_number).first.try(:reference_number)
    @lte = Invoice.select(:reference_number).order(year: :desc, reference_number: :desc).first.try(:reference_number)
  end

  def create
    ReceiptWizardWorker.perform_async(wizard_params)

    redirect_to admin_invoices_path, notice: "Ustvarjam račune"
  end

  def email
    customer = resource.customer

    unless customer.billing_email.present?
      return redirect_to(admin_invoice_path, notice: "Ni plačilnega kontakta ali pa ta nima nastavljenega e-maila")
    end

    Mailer.delay.invoice_to_customer(resource.id)
    redirect_to admin_invoice_path, notice: "Račun poslan na #{customer.billing_email}"
  end

  def email_due
    unless resource.due?
      return redirect_to(admin_invoice_path, notice: "Račun še ni zapadel, zato ne bomo poslali opomina.")
    end

    customer = resource.customer

    unless customer.billing_email.present?
      return redirect_to(admin_invoice_path, notice: "Ni plačilnega kontakta ali pa ta nima nastavljenega e-maila")
    end

    Mailer.delay.invoice_due_to_customer(resource.id)
    redirect_to admin_invoice_path, notice: "Opomin poslan na #{customer.billing_email}"
  end

  def build_for_subscription
    subscription = Subscription.find(params[:subscription_id])

    wizard = ReceiptWizard.new(wizard_params)
    unless subscription.plan.yearly?
      wizard.issue_id = Issue.order(published_at: :desc).first.id
    end
    @invoice = wizard.build_receipt_for_subscription subscription

    unless @invoice.save
      return render text: @invoice.errors.inspect
    end

    redirect_to admin_invoice_path(@invoice)
  end

  def build_partial_for_subscription
    subscription = Subscription.find(params[:subscription_id])
    issues_left = params[:issues_left]

    unless issues_left.present?
      return redirect_to :back, notice: "Please provide issues left"
    end

    wizard = ReceiptWizard.new(wizard_params)
    @invoice = wizard.build_partial_receipt_for_subscription(subscription, issues_left)

    unless @invoice.save
      return render text: @invoice.errors.inspect
    end

    render json: {receipt_id: @invoice.id, redirect: admin_invoice_path(@invoice)}
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

  def print_all
    @invoices = Invoice.all

    if lte = params[:lte]
      @invoices = @invoices.where("year = #{params[:year]} AND reference_number <= #{lte}")
    end
    if gte = params[:gte]
      @invoices = @invoices.where("year = #{params[:year]} AND reference_number >= #{gte}")
    end
    @invoices = @invoices.order(:year, :reference_number)

    unless params[:include_einvoiced].present?
      @invoices = @invoices.reject { |i| i.customer.einvoice? }
    end

    render layout: 'print'
  end

  private

  def collection
    @invoices ||= Invoice.order(year: :desc, reference_number: :desc).page(params[:page]).per(50)
  end

  def resource
    return unless params[:id]
    @invoice = Invoice.find_by(receipt_id: params[:id])
  end

  def set_page_title
    @page_title = 'Računi'
  end

  def wizard_params
    return @wizard_params if @wizard_params
    @wizard_params = params[:receipt_wizard] || {}
    @wizard_params.merge!(type: :invoice)
  end
end
