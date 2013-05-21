class PagesController < ApplicationController
  skip_before_filter :authenticate

  def index
    @copy = Copy.find_by_page_code 'pages_index'
  end
end
