class ArticlesController < InheritedResources::Base
  private

  def resource_params
    return [] if request.get?
    [params.require(:article).permit(:section_id, :issue_id, :title, :abstract_html, :abstract_english_html)]
  end
end