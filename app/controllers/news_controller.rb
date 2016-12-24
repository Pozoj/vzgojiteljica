# frozen_string_literal: true
class NewsController < ApplicationController
  skip_before_filter :authenticate, only: [:index]

  def index
    @copy = Copy.find_by_page_code 'news_index'
    respond_with collection
  end

  def show
    respond_with resource
  end

  def new
    @news = News.new
    respond_with resource
  end

  def create
    @news = News.create resource_params
    respond_with resource
  end

  def edit
    respond_with resource
  end

  def update
    resource.update_attributes resource_params
    respond_with resource
  end

  def destroy
    resource.destroy
    respond_with resource
  end

  private

  def collection
    @news ||= News.page(params[:page]).order(created_at: :desc)
  end

  def resource
    return unless params[:id]
    @news ||= News.find(params[:id])
  end

  def resource_params
    params.require(:news).permit(:title, :body_html)
  end
end
