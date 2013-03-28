class IssuesController < InheritedResources::Base
  respond_to :json, :only => [:cover, :document]

  def index
    @issues_by_years = Issue.all.order(year: :desc, issue: :asc).group_by { |issue| issue.year }
  end

  def cover
    resource.cover = params[:issue][:cover]
    resource.save
  end

  def document
    resource.document = params[:issue][:document]
    resource.save
  end

  private

    def resource_params
      return [] if request.get?
      [params.require(:issue).permit(:year, :issue, :published_at)]
    end
end
