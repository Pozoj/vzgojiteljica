class OrdersController < InheritedResources::Base
  before_filter :authenticate
  skip_before_filter :authenticate, only: [:new, :create]

  def index
    unless params[:all]
      @orders = collection.where(processed: false)
    end
  end

  def create
    create!(:notice => "Hvala! Vaše naročilo je bilo uspešno sprejeto.") do
      AdminMailer.new_order(@order.id)
      redirect_to root_url
    end
  end

  def mark_processed
    resource.processed = true    
    resource.save!
    redirect_to resource
  end

  private

    def resource_params
      return [] if request.get?
      [params.require(:order).permit(:title, :name, :address, :post_id, :phone, :fax, :email, :vat_id, :place_and_date, :comments, :quantity)]
    end
end