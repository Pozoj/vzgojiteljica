# frozen_string_literal: true
class Authorship < ActiveRecord::Base
  belongs_to :author
  belongs_to :article
  belongs_to :institution
end
