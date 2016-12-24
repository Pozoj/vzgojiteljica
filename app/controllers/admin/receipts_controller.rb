# frozen_string_literal: true
class Admin::ReceiptsController < Admin::AdminController
  skip_before_filter :authenticate, only: [:print]

  def show
    respond_with resource
  end

  def pdf
    redirect_to resource.pdf_idempotent
  end

  def print
    respond_with resource, layout: 'print'
  end
end
