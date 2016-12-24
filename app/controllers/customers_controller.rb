# frozen_string_literal: true
class CustomersController < Admin::AdminController
  skip_before_filter :authenticate, only: [:public_show, :ingest_order_form]
  layout 'public'

  ###
  ### UNAUTHENTICATED
  ###
  def public_show
    token = params[:token].upcase
    @customer = Customer.find_by(token: token)
    return redirect_to root_path unless @customer

    @invoices = @customer.invoices
    @last_paid_invoice = @invoices.paid.order(created_at: :desc).first
    @subscriptions = @customer.subscriptions.paid.active
    @order_forms = @customer.order_forms.where(year: Date.today.year)
    @order_form ||= @customer.order_forms.new

    @page_title = @customer.to_s
  end

  def ingest_order_form
    return redirect_to root_path unless params[:token].present?

    token = params[:token].upcase
    @customer = Customer.find_by(token: token)
    return redirect_to root_path unless @customer

    if !params[:order_form] || (params[:order_form] && !params[:order_form].any?)
      return redirect_to root_path
    end

    order_form_params = params.require(:order_form).permit(:form_id, :authorizer)
    @order_form = @customer.order_forms.new(order_form_params)
    @order_form.issued_at = DateTime.now
    if @order_form.valid?
      @order_form.save
      redirect_to token_path(@customer.token), notice: 'Vaša naročilnica je bila sprejeta. Najlepša hvala!'
    else
      public_show
      render action: 'public_show'
    end
  end
end
