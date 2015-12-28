class CopiesController < ApplicationController
  skip_before_filter :authenticate, only: [:show]

  def show
    respond_with resource
  end

  def edit
    respond_with resource
  end

  def create
    @copy = Copy.create resource_params
    respond_with resource
  end

  def update
    resource.update_attributes resource_params
    respond_with resource
  end

  private

  def resource
    return unless params[:id]
    @copy ||= Copy.find_by page_code: params[:id]
  end

  def resource_params
    params.require(:copy).permit(:title, :copy_html)
  end
end
