# frozen_string_literal: true
class InquiriesController < ApplicationController
  skip_before_filter :authenticate, only: [:index, :show, :create]

  def index
    @inquiry = Inquiry.new
    @inquiries = Inquiry.published
    respond_with collection
  end

  def all
    respond_with collection
  end

  def show
    respond_with resource
  end

  def create
    if params[:inquiry][:helmet] && params[:inquiry][:helmet].present?
      render text: 'Thank you!'
      return
    end

    @inquiry = Inquiry.new(resource_params)
    if @inquiry.save
      AdminMailer.delay.new_inquiry(@inquiry.id)
      Mailer.delay.inquiry_submitted(@inquiry.id)
      respond_with resource
    else
      render action: :new, notice: 'Napaka pri postavljanju vprašanja!'
    end
  end

  def edit
    respond_with resource
  end

  def update
    resource.update_attributes resource_params
    respond_with resource
  end

  def destroy
    resource.destroy
    respond_with resource
  end

  def answer_question
    respond_with resource
  end

  def answer
    if resource.update_attributes params.require(:inquiry).permit(:answer, :published)
      Mailer.delay.inquiry_answer(resource.id)
    end
    respond_with resource
  end

  private

  def collection
    @inquiries ||= Inquiry.all
    @inquiries = @inquiries.order(created_at: :desc).page(params[:page])
  end

  def resource
    return unless params[:id]
    @inquiry ||= Inquiry.find(params[:id])
  end

  def resource_params
    if signed_in?
      params.require(:inquiry).permit(:name, :institution, :email, :phone, :subject, :question, :helmet, :published)
    else
      params.require(:inquiry).permit(:name, :institution, :email, :phone, :subject, :question, :helmet)
    end
  end
end
