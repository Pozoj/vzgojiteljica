class InquiriesController < InheritedResources::Base
  skip_before_filter :authenticate, only: [:create]

  def destroy
    destroy! { all_inquiries_path }
  end

  def create
    if params[:inquiry][:helmet] and params[:inquiry][:helmet].present?
      render :text => "Thank you!"
      return
    end

  	create! { inquiries_path }
  end

  def answer
    resource.update_attributes params.require(:inquiry).permit(:answer)

    redirect_to resource_path
  end

  def update
  	update! { resource_path }
  end

  private

    def resource_params
      return [] if request.get?
      [params.require(:inquiry).permit(:name, :institution, :email, :phone, :subject, :question, :helmet)]
    end
end