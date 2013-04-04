class InquiriesController < InheritedResources::Base
  skip_before_filter :authenticate, only: [:new, :create]

  def destroy
    destroy! { all_inquiries_path }
  end


  def create
  	create! { inquiries_path }
  end

  def update
  	update! { inquiries_path }
  end

  private

    def resource_params
      return [] if request.get?
      [params.require(:inquiry).permit(:name, :institution, :email, :phone, :subject, :question)]
    end
end