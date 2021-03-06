# frozen_string_literal: true
class Admin::OrderFormsController < Admin::AdminController
  def index
    @years = OrderForm.years
    @year_now = DateTime.now.year
    @all_order_forms = OrderForm.select(:id, :form_id).order(issued_at: :desc).map { |i| [i.id, i.form_id] }

    @order_forms = collection
    if params[:filter_year]
      @order_forms = @order_forms.where(year: params[:filter_year])
    elsif params[:filter_year_all]
    elsif params[:unprocessed]
      @order_forms = @order_forms.not_processed
      @year_now = nil
    elsif params[:active]
      @order_forms = @order_forms.active
      @year_now = nil
    else
      @order_forms = @order_forms.where(year: @year_now)
    end

    respond_with collection
  end

  def process_it
    case params[:kind]
    when 'attach'
      resource.process_attach!(user_id: current_user.id)
    when 'renew'
      resource.process_renew!(user_id: current_user.id)
    end

    redirect_to admin_order_form_path(resource)
  end

  def mark_processed
    resource.processed!(user_id: current_user.id)
    if resource.reload.processed?
      redirect_to admin_order_form_path(resource), notice: 'Označeno kot obdelano'
    else
      redirect_to admin_order_form_path(resource)
    end
  end

  def show
    @order_form = resource

    subscribers = Subscriber.all.order(:title, :name)
    if resource.order && resource.order.post_id
      subscribers = subscribers.where(post_id: resource.order.post_id)
    end
    @all_subscribers = subscribers.group_by(&:customer).map do |customer, subscribers|
      [
        customer.to_s,
        subscribers.map { |s| [s.to_s, s.id] }
      ]
    end
  end

  def new
    @order_form = OrderForm.new
  end

  def create
    order_form_params = params.require(:order_form).permit(:form_id, :authorizer, :customer_id, :issued_at, :processed_at, :start, :end, :document)
    @order_form = OrderForm.new(order_form_params)

    if @order_form.save
      redirect_to admin_order_form_path(@order_form)
    else
      render 'new'
    end
  end

  def edit
    @order_form = resource
  end

  def update
    resource.update_attributes resource_params
    if resource.valid?
      respond_with resource, location: -> { admin_order_form_path(@order_form) }
    else
      respond_with resource, location: -> { edit_admin_order_form_path(@order_form) }
    end
  end

  def destroy
    order_form = Order.find(params[:id])
    if order_form.destroy
      redirect_to admin_order_forms_path, notice: 'Naročilnica uspešno izbrisana'
    end
  end

  def download
    if resource.document.file?
      redirect_to resource.document.expiring_url(10)
    else
      redirect_to :back
    end
  end

  private

  def collection
    @order_forms ||= OrderForm.order(issued_at: :desc, form_id: :desc).page(params[:page]).per(50)
  end

  def resource
    return unless params[:id]
    @order_form ||= OrderForm.find(params[:id])
  end

  def resource_params
    params.require(:order_form)
  end

  def set_page_title
    @page_title = 'Naročilnice'
  end
end
