class CopiesController < InheritedResources::Base
  def create
    create! { copy_path(resource) }
  end
  def update
    update! { copy_path(resource) }
  end

  private

    def resource
      Copy.find_by page_code: params[:id]
    end

    def resource_params
      return [] if request.get?
      [params.require(:copy).permit(:title, :copy_html)]
    end
end
