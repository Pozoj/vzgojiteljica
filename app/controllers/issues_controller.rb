# frozen_string_literal: true
class IssuesController < ApplicationController
  skip_before_filter :authenticate, only: [:index, :show]

  def index
    @issues_by_years = Issue.published.sorted.group_by(&:year)
    respond_with @issues_by_years
  end

  def show
    @issue = Issue.published.find_by(id: params[:id])
  end
end
