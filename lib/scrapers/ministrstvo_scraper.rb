# frozen_string_literal: true
require 'nokogiri'
require 'open-uri'
require 'openssl'
require 'ostruct'
require 'iban-tools'

module Scrapers
  class MinistrstvoScraper
    ROOT = 'https://krka1.mss.edus.si/registriweb'
    MAIN_URL = '/SeznamVrtci.aspx'

    def initialize
      log "Initializing"
    end

    def log(message)
      puts "[MinistrstvoScraper] #{message}"
    end

    def open_main
      open_url(MAIN_URL)
    end

    def open_url(url)
      log "Opening url #{url}"
      Nokogiri::HTML(open(ROOT + url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE))
    end

    def only_numbers(string)
      string.gsub(/[^0-9]/, '')
    end

    def parse_bank_account(bank_account)
      bank_account = IBANTools::IBAN.new("SI56#{only_numbers(bank_account)}").prettify

      if IBANTools::IBAN.valid?(bank_account)
        return bank_account
      end

      nil
    end

    def determine_legal_status(legal_status)
      case legal_status
      when 'Javni vrtec'
        :public
      when 'Zasebni vrtec'
        :private_company
      when 'Zasebni vzgojitelj'
        :private_person
      else
        raise 'Unsupported legal status found: ' + legal_status.inspect
      end
    end

    def determine_if_part_of_primary(part_of_primary)
      part_of_primary == 'Da'
    end

    def fetch_primary(url, part_of_primary)
      doc = open_url('/' + url)
      return parse_details_page(doc) unless part_of_primary

      primary_el = doc.css('#ctlContentHolder_ctlMaticnaLink').first
      return unless primary_el

      primary_doc = open_url('/' + primary_el.attr('href'))
      parse_details_page(primary_doc)
    end

    def parse_details_page(doc)
      entity = OpenStruct.new
      entity.registration_number = doc.css('#ctlContentHolder_lblMaticnaStevilka').first && only_numbers(doc.css('#ctlContentHolder_lblMaticnaStevilka').first.text.strip).to_i
      entity.title = doc.css('#ctlContentHolder_lblNaziv').first && doc.css('#ctlContentHolder_lblNaziv').first.text.strip
      entity.address = doc.css('#ctlContentHolder_lblUlica').first && doc.css('#ctlContentHolder_lblUlica').first.text.strip
      entity.post_id = doc.css('#ctlContentHolder_lblPosta').first && only_numbers(doc.css('#ctlContentHolder_lblPosta').first.text.strip).to_i
      entity.phone = doc.css('#ctlContentHolder_lblTelefon').first && doc.css('#ctlContentHolder_lblTelefon').first.text.strip
      entity.fax = doc.css('#ctlContentHolder_lblFax').first && doc.css('#ctlContentHolder_lblFax').first.text.strip
      entity.vat_id = doc.css('#ctlContentHolder_lblDavcnaSt').first && doc.css('#ctlContentHolder_lblDavcnaSt').first.text.strip
      entity.account_number = doc.css('#ctlContentHolder_lblTrr').first && parse_bank_account(doc.css('#ctlContentHolder_lblTrr').first.text.strip)
      entity.email = doc.css('#ctlContentHolder_ctlEmail').first && doc.css('#ctlContentHolder_ctlEmail').first.text.strip

      entity
    end

    def parse_row(row)
      entity = OpenStruct.new
      cols = row.css('td')

      cols.shift.text.strip                   # STATISTICNA REGIJA
      cols.shift.text.strip                   # OBCINA
      details_el             = cols.shift     # NAZIV VRTCA
      details_url            = details_el.css('a').attr('href').value
      entity.title           = details_el.text.strip
      entity.address         = cols.shift.text.strip # NASLOV
      entity.post_id         = only_numbers(cols.shift.text.strip).to_i # POSTNA STEVILKA
      cols.shift # POSTA
      entity.phone           = cols.shift.text.strip # TEL
      entity.fax             = cols.shift.text.strip # FAX
      entity.email           = cols.shift.text.strip # E-NASLOV
      entity.website         = cols.shift.text.strip # Spletna stran (URL)
      entity.legal_status    = determine_legal_status(cols.shift.text.strip) # Pravni status
      entity.part_of_primary = determine_if_part_of_primary(cols.shift.text.strip) # Pri OS
      entity.vat_id          = cols.shift.text.strip # Davcna
      entity.account_number  = parse_bank_account(cols.shift.text.strip) # TRR

      entity.primary = fetch_primary(details_url, entity.part_of_primary)

      entity
    end

    def parse
      log 'Parsing ...'

      doc = open_main
      rows = doc.xpath('//div/table/tr[2]/td/table').css('tr')
      rows.shift # Remove first row which is the header
      rows.map { |row| parse_row(row) }
    end
  end
end
