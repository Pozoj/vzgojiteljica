# frozen_string_literal: true
class Admin::KeywordsController < Admin::AdminController
  respond_to :html, :json

  def index
    respond_with collection
  end

  def create
    @keyword = Keyword.create resource_params
    respond_with resource, location: -> { keywords_path }
  end

  def create_simple
    @keyword = Keyword.create resource_params

    render json: {
      id: @keyword.id,
      keyword: @keyword.keyword
    }
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
