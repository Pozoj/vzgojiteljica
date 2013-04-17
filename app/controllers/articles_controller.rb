class ArticlesController < InheritedResources::Base
  skip_before_filter :authenticate, only: :search

  def search
    if params[:query]
      @search = Search.new params[:query]
      @articles = @search.perform
    end
    
    render :action => :index
  end

  private

  def collection
  	(@articles or end_of_association_chain.includes(:authors, :issue)).order(:title, :issue_id).page params[:page]
  end

  def resource_params
    return [] if request.get?
    [params.require(:article).permit(:section_id, :issue_id, :title, :abstract_html, :abstract_english_html)]
  end
end