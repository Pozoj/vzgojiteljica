# frozen_string_literal: true
Cmxl.config[:raise_line_format_errors] = false

class MyFieldParser < Cmxl::Field
  self.tag = 86 # define which MT940 tag your parser can handle. This will automatically register your parser and overwriting existing parsers
  self.parser = /\/(SIO|ROC)\/(?<transaction_codes>.*)\/(SIB|NRF)\/(?<reference>.*)\/ACC\/(?<iban>.*)\/PAR\/(?<entity>.*)(SEPA)?/ # the regex to parse the line. Use named regexp to access your match.

  def iban
    data['iban']
  end

  def reference
    data['reference'].try(:gsub, '00/', '')
  end

  def entity
    data['entity']
  end

  def entity_parts
    entity && entity.split(',')
  end

  def entity_title
    entity_parts[0]
  end

  def entity_subtitle
    entity_parts[1]
  end

  def entity_address
    entity_parts[2]
  end

  def entity_country
    entity_parts[3]
  end
end
