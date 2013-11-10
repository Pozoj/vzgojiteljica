class OrdersController < InheritedResources::Base
  before_filter :authenticate
  skip_before_filter :authenticate, only: [:new, :create]

  def create
    create!(:notice => "Hvala! Vaše naročilo je bilo uspešno sprejeto.") { root_url }
  end

  private

    def resource_params
      return [] if request.get?
      [params.require(:order).permit(:title, :name, :address, :post_id, :phone, :fax, :email, :vat_id, :place_and_date, :comments, :quantity)]
    end
end