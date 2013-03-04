class CopiesController < InheritedResources::Base
  protected

  def resource
    Copy.find_by page_code: params[:id]
  end
end
