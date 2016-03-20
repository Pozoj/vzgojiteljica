class Admin::OffersController < Admin::ReceiptsController
  def index
    @years = Offer.years
    @year_now = DateTime.now.year
    @all_offers = Offer.select(:id, :receipt_id).order(year: :desc, reference_number: :desc).map { |i| [i.receipt_id, i.receipt_id] }

    @offers = collection
    if params[:filter_year]
      @offers = @offers.where(year: params[:filter_year])
    elsif params[:filter_year_all]
    else
      @offers = @offers.where(year: @year_now)
    end
    respond_with collection
  end

  def wizard
    @wizard = ReceiptWizard.new(wizard_params)
    @last = Offer.select(:reference_number).
            where(year: Date.today.year).
            order(year: :desc, reference_number: :desc).
            first.try(:reference_number) || 0
  end

  def print_wizard
    @gte = Offer.select(:reference_number).order(:year, :reference_number).first.try(:reference_number)
    @lte = Offer.select(:reference_number).order(year: :desc, reference_number: :desc).first.try(:reference_number)
  end

  def create
    ReceiptWizardWorker.perform_async(wizard_params)
    redirect_to admin_offers_path, notice: "Ustvarjam ponudbe"
  end

  def email
    customer = resource.customer

    unless customer.billing_email.present?
      return redirect_to(admin_offer_path, notice: "Ni plačilnega kontakta ali pa ta nima nastavljenega e-maila")
    end

    Mailer.delay.offer_to_customer(resource.id)
    redirect_to admin_offer_path, notice: "Račun poslan na #{customer.billing_email}"
  end

  def email_due
    unless resource.due?
      return redirect_to(admin_offer_path, notice: "Račun še ni zapadel, zato ne bomo poslali opomina.")
    end

    customer = resource.customer

    unless customer.billing_email.present?
      return redirect_to(admin_offer_path, notice: "Ni plačilnega kontakta ali pa ta nima nastavljenega e-maila")
    end

    Mailer.delay.offer_due_to_customer(resource.id)
    redirect_to admin_offer_path, notice: "Opomin poslan na #{customer.billing_email}"
  end

  def print_all
    @offers = Offer.all

    if lte = params[:lte]
      @offers = @offers.where("year = #{params[:year]} AND reference_number <= #{lte}")
    end
    if gte = params[:gte]
      @offers = @offers.where("year = #{params[:year]} AND reference_number >= #{gte}")
    end
    @offers = @offers.order(:year, :reference_number)

    unless params[:include_eofferd].present?
      @offers = @offers.reject { |i| i.customer.eoffer? }
    end

    render layout: 'print'
  end

  def create_for_customer
    customer = Customer.find(params[:customer_id])

    unless customer
      redirect_to :back
    end

    wizard = ReceiptWizard.new(type: :offer)
    offer = wizard.create_receipt_for_customer(customer)
    if offer
      redirect_to admin_offer_path(offer)
    else
      redirect_to admin_customer_path(customer), notice: 'Ponudbe ni bilo mogoče ustvariti'
    end
  end

  private

  def collection
    @offers ||= Offer.order(year: :desc, reference_number: :desc).page(params[:page]).per(50)
  end

  def resource
    return unless params[:id]
    @offer ||= Offer.find_by(receipt_id: params[:id])
  end

  def set_page_title
    @page_title = 'Ponudbe'
  end

  def wizard_params
    return @wizard_params if @wizard_params
    @wizard_params = params[:receipt_wizard] || {}
    @wizard_params.merge!(type: :offer)
  end
end
