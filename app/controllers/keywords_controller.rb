class KeywordsController < ApplicationController
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
    @keyword = Keyword.new
    respond_with resource
  end

  def create
    @keyword = Keyword.create resource_params
    respond_with resource, location: -> { keywords_path }
  end

  def edit
    respond_with resource
  end

  def update
    resource.update_attributes resource_params
    respond_with resource, location: -> { keywords_path }
  end

  def destroy
    resource.destroy
    respond_with resource
  end

  private

  def collection
    @keywords ||= Keyword.all.order(:keyword).page(params[:page])
  end

  def resource
    return unless params[:id]
    @keyword ||= Keyword.find(params[:id])
  end

  def resource_params
    params.require(:keyword).permit(:keyword)
  end
end
