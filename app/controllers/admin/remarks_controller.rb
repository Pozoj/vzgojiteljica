class Admin::RemarksController < InheritedResources::Base
  before_filter :authenticate
  layout "admin"

  def create
    @resource.user = current_user
  end
end
