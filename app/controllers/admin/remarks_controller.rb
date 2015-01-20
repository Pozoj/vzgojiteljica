class Admin::RemarksController < Admin::AdminController
  def create
    @remark = Remark.new params[:remark], without_protection: true
    @remark.user = current_user
    create! { polymorphic_path([:admin, @remark.remarkable]) }
  end

  def update
    update! { polymorphic_path([:admin, resource.remarkable]) }
  end

  def destroy
    destroy! { polymorphic_path([:admin, resource.remarkable]) }
  end
end
