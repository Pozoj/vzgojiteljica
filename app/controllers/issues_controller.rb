class IssuesController < ApplicationController
  skip_before_filter :authenticate, only: [:index, :show]
  respond_to :json, :only => [:cover, :document]

  def index
    @issues_by_years = Issue.sorted.group_by { |issue| issue.year }
    respond_with @issues_by_years
  end

  def all
    respond_with collection
  end

  def show
    respond_with resource
  end

  def new
    @issue = Issue.new
    respond_with resource
  end

  def create
    @issue = Issue.create resource_params
    respond_with resource
  end

  def edit
    respond_with resource
  end

  def update
    resource.update_attributes resource_params
    respond_with resource
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
    return unless params[:id]
    @issue ||= Issue.find(params[:id])
  end

  def collection
    @issues ||= Issue.all.order 'year DESC, issue DESC'
  end

  def resource_params
    params.require(:issue).permit(:year, :issue, :published_at)
  end
end
