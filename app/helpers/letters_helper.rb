# frozen_string_literal: true
module LettersHelper
  def interpolate_letter(body, recipient)
    body = body.gsub('@@CUSTOMER@@', recipient.to_s)
    body
  end
end
