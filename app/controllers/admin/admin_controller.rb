class Admin::AdminController < ApplicationController
  before_filter :authenticate
  layout "admin"
end
