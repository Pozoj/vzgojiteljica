class OrdersController < InheritedResources::Base
  before_filter :authenticate
  skip_before_filter :authenticate, only: [:new, :create]

  private

    def resource_params
      return [] if request.get?
      [params.require(:order).permit(:title, :name, :address, :post_id, :phone, :fax, :email, :vat_id, :place_and_date, :comments, :quantity)]
    end
end