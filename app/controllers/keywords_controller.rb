class KeywordsController < InheritedResources::Base
  before_filter :authenticate

  def create
    create! { keywords_path }
  end
  def update
    update! { keywords_path }
  end

  private

  def collection
    Keyword.all.order(:keyword).page params[:page]
  end

  def resource_params
    return [] if request.get?
    [params.require(:keyword).permit(:keyword)]
  end
end
