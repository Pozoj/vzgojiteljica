class PagesController < ApplicationController
  def index
    @copy = Copy.find_by_page_code 'pages_index'
  end
end
