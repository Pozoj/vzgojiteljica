class ArticlesController < InheritedResources::Base
  private

  def collection
  	end_of_association_chain.order(:title).page params[:page]
  end

  def resource_params
    return [] if request.get?
    [params.require(:article).permit(:section_id, :issue_id, :title, :abstract_html, :abstract_english_html)]
  end
end