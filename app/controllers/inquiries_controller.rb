class InquiriesController < ApplicationController
  skip_before_filter :authenticate, only: [:create]

  def index
    @inquiry = Inquiry.new
    respond_with collection
  end

  def all
    respond_with collection
  end

  def show
    respond_with resource
  end

  def create
    if params[:inquiry][:helmet] and params[:inquiry][:helmet].present?
      render :text => "Thank you!"
      return
    end

    @inquiry = Inquiry.create resource_params
    respond_with resource
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
    resource.update_attributes params.require(:inquiry).permit(:answer)
    respond_with resource
  end

  private

  def collection
    @inquiries = Inquiry.all.page(params[:page])
  end

  def resource
    @inquiry ||= Inquiry.find(params[:id])
  end

  def resource_params
    params.require(:inquiry).permit(:name, :institution, :email, :phone, :subject, :question, :helmet)
  end
end