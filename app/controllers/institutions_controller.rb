class InstitutionsController < InheritedResources::Base
  before_filter :authenticate

  def create
    create! { institutions_path }
  end
  def update
    update! { institutions_path }
  end


  private
    def collection
      Institution.all.order(:name)
    end

    def resource_params
      return [] if request.get?
      [params.require(:institution).permit(:name)]
    end
end
