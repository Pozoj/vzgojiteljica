class Admin::EntitiesController < InheritedResources::Base
  before_filter :authenticate
  layout "admin"

  def index
    @entities = Entity.search(params[:filter]).page(params[:page]).per(params[:per_page] || 20)
  end
end
