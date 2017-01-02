# frozen_string_literal: true
class Admin::InstitutionsController < Admin::AdminController
  def index
    respond_with collection
  end
  
  private

  def collection
    @institutions ||= Institution.all.page(params[:page])
  end
end
