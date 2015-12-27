class Admin::EntitiesController < Admin::AdminController
  def index
    @entities = Entity.search(params[:filter]).
    order(:title, :name, :type)
    @entities_count = @entities.count

    @entities = @entities.
    page(params[:page]).
    per(params[:per_page] || 20)
  end
end
