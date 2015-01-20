class InstitutionsController < ApplicationController
  before_filter :authenticate

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
    @institution = Institution.new
    respond_with resource
  end

  def create
    @institution = Institution.create resource_params
    respond_with resource, location: -> { institutions_path }
  end

  def edit
    respond_with resource
  end

  def update
    resource.update_attributes resource_params
    respond_with resource, location: -> { institutions_path }
  end

  def destroy
    resource.destroy
    respond_with resource
  end

  private

  def collection
    @institutions ||= Institution.all.page(params[:page])
  end

  def resource
    @institution ||= Institution.find(params[:id])
  end

  def resource_params
    params.require(:institution).permit(:name)
  end
end
