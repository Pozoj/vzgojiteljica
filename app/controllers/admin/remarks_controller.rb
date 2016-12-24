# frozen_string_literal: true
class Admin::RemarksController < Admin::AdminController
  def index
    @remarks = collection
  end

  def create
    @remark = Remark.new params[:remark], without_protection: true
    @remark.user = current_user
    @remark.save
    respond_with resource, location: -> { polymorphic_path([:admin, @remark.remarkable]) }
  end

  def update
    resource.update_attributes params[:remark]
    respond_with resource, location: -> { polymorphic_path([:admin, resource.remarkable]) }
  end

  def destroy
    resource.destroy
    respond_with resource, location: -> { polymorphic_path([:admin, resource.remarkable]) }
  end

  private

  def resource
    return unless params[:id]
    @remark ||= Remark.find(params[:id])
  end

  def collection
    @remarks ||= Remark.all.order(created_at: :desc).page(params[:page]).per(25)
  end

  def set_page_title
    @page_title = 'Opombe'
  end
end
