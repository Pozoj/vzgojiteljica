# frozen_string_literal: true
class Admin::LettersController < Admin::AdminController
  before_filter :set_page_title

  def index
    @letters = Letter.all.order(:id)
    respond_with collection
  end

  def new
    @letter = Letter.new
  end

  def create
    @letter = Letter.new(resource_params)
    @letter.save
    respond_with resource, location: -> { admin_letter_path(resource) }
  end

  def show
    respond_with resource
  end

  def edit
    respond_with resource
  end

  def update
    resource.update_attributes(resource_params)
    respond_with resource, location: -> { admin_letter_path(resource) }
  end

  def destroy
    resource.destroy
    respond_with resource, location: -> { admin_letters_path }
  end

  def print
    if params[:recipient_ids].present?
      ids = params[:recipient_ids].split(',')
      @recipients = Subscriber.where(id: ids)
    else
      @recipients = Subscriber.active

      case params[:recipient_category]
      when 'paid'
        @recipients = @recipients.paid
      when 'free'
        @recipients = @recipients.free
      when 'rewards'
        # TODO
      end
    end

    @letter = resource
    render layout: 'print'
  end

  private

  def resource_params
    params.require(:letter)
  end

  def resource
    @letter ||= Letter.find_by(id: params[:id])
  end

  def collection
    @letters ||= Letter.order(id: :desc).page(params[:page])
  end

  def set_page_title
    @page_title ||= 'Dopisi'
  end
end
