# frozen_string_literal: true
class Admin::ArticlesController < Admin::AdminController
  def index
    respond_with collection
  end

  def show
    respond_with resource
  end

  def new
    @article = Article.new
    @article.issue = Issue.find_by(id: params[:issue_id])
    respond_with resource
  end

  def create
    @article = Article.create(resource_params)
    respond_with resource, location: -> { admin_issue_path(@article.issue) }
  end

  def edit
    respond_with resource
  end

  def update
    resource.update_attributes resource_params
    respond_with resource, location: -> { admin_issue_path(resource.issue) }
  end

  def destroy
    resource.destroy
    respond_with resource
  end

  private

  def collection
    @articles = (@articles ||= Article.includes(:authors, :issue)).order(:title, :issue_id).page(params[:page])
  end

  def resource
    return unless params[:id]
    @article ||= Article.find params[:id]
  end

  def resource_params
    params.require(:article).permit(:section_id, :issue_id, :title, :abstract_html, :abstract_english_html, author_ids: [], keyword_ids: [])
  end
end
