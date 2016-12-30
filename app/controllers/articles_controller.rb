# frozen_string_literal: true
class ArticlesController < ApplicationController
  skip_before_filter :authenticate

  def index
    respond_with collection
  end

  def search
    if params[:query]
      @search = Search.new params[:query]
      @articles = @search.perform
    end

    respond_with(collection) do |format|
      format.html { render action: :index }
    end
  end

  def show
    respond_with resource
  end

  private

  def collection
    @articles = (@articles ||= Article.includes(:authors, :issue)).order(issue_id: :desc, title: :asc).page(params[:page])
  end

  def resource
    return unless params[:id]
    @article ||= Article.find params[:id]
  end
end
