# frozen_string_literal: true
class PagesController < ApplicationController
  skip_before_filter :authenticate

  def index
    @copy = Copy.find_by_page_code 'pages_index'
  end

  def editorial_instructions
    @copy = Copy.find_by_page_code 'pages_editorial_instructions'
  end
end
