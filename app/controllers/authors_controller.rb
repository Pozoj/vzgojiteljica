# frozen_string_literal: true
class AuthorsController < ApplicationController
  skip_before_filter :authenticate

  def show
    respond_with resource
  end

  private

  def resource
    return unless params[:id]
    @author ||= Author.find(params[:id])
  end
end
