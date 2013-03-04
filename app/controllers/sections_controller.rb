class SectionsController < InheritedResources::Base
  before_filter :authenticate

  def create
    create! { sections_path }
  end
  def update
    update! { sections_path }
  end

  private

    def collection
      Section.all.order(:position)
    end

    def resource_params
      return [] if request.get?
      [params.require(:section).permit(:name, :position)]
    end
end
