class Admin::IssuesController < Admin::AdminController
  respond_to :json, only: [:cover, :document]

  def index
    @issues = collection
  end

  def show
    @issue = resource
  end

  def new
    @issue = Issue.new
    respond_with resource
  end

  def create
    @issue = Issue.create resource_params
    respond_with resource, location: -> { admin_issue_path(resource) }
  end

  def edit
    respond_with resource
  end

  def update
    resource.update_attributes resource_params
    respond_with resource, location: -> { admin_issue_path(resource) }
  end

  def edit_cover
    respond_with resource
  end

  def cover
    resource.cover = params[:issue][:cover]
    resource.save
  end

  def edit_document
    respond_with resource
  end

  def document
    resource.document = params[:issue][:document]
    resource.save
  end

  def destroy
    resource.destroy
    respond_with resource
  end

  private

  def resource
    @issue ||= Issue.find_by(id: params[:id])
  end

  def collection
    @issues ||= Issue.all.order(year: :desc, issue: :desc)
  end

  def resource_params
    params.require(:issue).permit(:year, :issue, :published_at, :num_pages)
  end
end
