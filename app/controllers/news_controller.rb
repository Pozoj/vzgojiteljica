class NewsController < InheritedResources::Base

  private

    def resource_params
      return [] if request.get?
      [params.require(:news).permit(:title, :body)]
    end
end
