# frozen_string_literal: true
class Admin::EntitiesController < Admin::AdminController
  def index
    @entities = Entity.search(params[:filter])
                      .order(:title, :name, :type)
    @entities_count = @entities.count

    @entities = @entities
                .page(params[:page])
                .per(params[:per_page] || 20)
  end

  private

  def set_page_title
    @page_title = 'Entitete'
  end
end
