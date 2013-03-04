class AuthorsController < InheritedResources::Base
  before_filter :authenticate

  private

    def collection
      Author.all.order(:last_name, :first_name)
    end

    def resource_params
      return [] if request.get?
      [params.require(:author).permit(:id, :first_name, :last_name, :email, :address, :post_id, :phone, :institution_id, :title, :education)]
    end
end
