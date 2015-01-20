class Admin::EntitiesController < Admin::AdminController
  def index
    @entities = Entity.search(params[:filter]).page(params[:page]).per(params[:per_page] || 20)
  end
end
