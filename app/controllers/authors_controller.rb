class AuthorsController < ApplicationController
  skip_before_filter :authenticate, only: [:show]

  def index
    respond_with collection
  end

  def all
    respond_with collection
  end

  def show
    respond_with resource
  end

  def new
    @author = Author.new
    respond_with resource
  end

  def create
    @author = Author.create resource_params
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

  private

  def collection
    @authors ||= Author.all.order(:last_name, :first_name).page(params[:page])
  end

  def resource
    @author ||= Author.find(params[:id])
  end

  def resource_params
    params.require(:author).permit(:id, :first_name, :last_name, :email, :address, :post_id, :phone, :institution_id, :title, :education)
  end
end
