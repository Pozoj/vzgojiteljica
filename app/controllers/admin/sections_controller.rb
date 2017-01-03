# frozen_string_literal: true
class Admin::SectionsController < Admin::AdminController
  def index
    respond_with collection
  end

  def show
    respond_with resource
  end

  def new
    @section = Section.new
    respond_with resource
  end

  def create
    @section = Section.create resource_params
    respond_with resource, location: -> { admin_sections_path }
  end

  def edit
    respond_with resource
  end

  def update
    resource.update_attributes resource_params
    respond_with resource, location: -> { admin_sections_path }
  end

  def destroy
    resource.destroy
    respond_with resource, location: -> { admin_sections_path }
  end

  private

  def collection
    @sections ||= Section.all.order(:position).page(params[:page])
  end

  def resource
    return unless params[:id]
    @section ||= Section.find(params[:id])
  end

  def resource_params
    params.require(:section).permit(:name, :position)
  end
end
