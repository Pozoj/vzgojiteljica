class Admin::RemarksController < InheritedResources::Base
  before_filter :authenticate
  layout "admin"

  def create
    @resource = Remark.new params[:remark], without_protection: true
    @resource.user = current_user
    create! { polymorphic_path([:admin, @resource.remarkable]) }
  end

  def update
    update! { polymorphic_path([:admin, resource.remarkable]) }
  end

  def destroy
    destroy! { polymorphic_path([:admin, resource.remarkable]) }
  end
end
