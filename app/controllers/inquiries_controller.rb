class InquiriesController < InheritedResources::Base
  skip_before_filter :authenticate, only: [:new, :create]

  private

    def resource_params
      return [] if request.get?
      [params.require(:inquiry).permit(:name, :institution, :email, :phone, :subject, :question)]
    end
end