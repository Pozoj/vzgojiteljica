class AuthorsController < InheritedResources::Base
  before_filter :authenticate
end
