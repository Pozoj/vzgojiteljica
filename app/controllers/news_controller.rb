class NewsController < InheritedResources::Base
  def index
    @copy = Copy.find_by_page_code 'news_index'
    index!
  end

  private

    def resource_params
      return [] if request.get?
      [params.require(:news).permit(:title, :body_html)]
    end
end
