class Admin::AdminController < ApplicationController
  before_filter :authenticate
  layout "admin"

  def index
    @last_issue = Issue.order(:published_at).last
  end
end
