# frozen_string_literal: true
class EboniteteScraper
  ROOT = 'http://www.ebonitete.si/'
  SEARCH_URL = 'iskalnik.aspx?q='

  def initialize(vat_id)
    @vat_id = vat_id
    log "Initializing with #{vat_id}"
  end

  def log(message)
    puts "[EBoniteteScraper] #{message}"
  end

  def search_url
    "#{ROOT}#{SEARCH_URL}#{@vat_id}"
  end

  def data_url
    return unless @data_url
    "#{ROOT}#{@data_url}"
  end

  def open_url(url)
    log "Opening url #{url}"
    Nokogiri::HTML(open(url))
  end

  def search
    log "Searching for #{@vat_id}"
    doc = open_url(search_url)
    trs = doc.css('#searchRezultati table.mGrid tr')
    unless trs.length == 2
      puts 'ERROR, entity mismatch'
      return
    end

    tr = trs.last
    @data_url = tr.css('#ctl00_cphVsebina_gvPodjetja_ctl02_EditHyperLink1').attr('href').value
  end

  def parse_bank_account(doc)
    map_node = doc.css('#ctl00_cphVsebina_lnkZemljevid').first
    bank_node = map_node.parent.previous.previous
    account_node = bank_node.css('.podatkiPodjetjaInfo')
    accounts = account_node.children.reject do |child|
      !child.is_a?(Nokogiri::XML::Text) ||
        (child.is_a?(Nokogiri::XML::Text) && child.text.strip == '')
    end.map do |child|
      parts = child.text.split(' ')
      {
        account_number: IBANTools::IBAN.new("SI56#{parts.shift}").prettify,
        bank: parts.reject { |part| part.length < 2 }.join(' ')
      }
    end.reject do |account|
      !IBANTools::IBAN.valid?(account[:account_number])
    end
  end

  def parse
    log 'Parsing ...'
    search

    return unless data_url

    doc = open_url(data_url)

    {
      title: doc.css('#ctl00_cphVsebina_lblKratekNaziv').text.strip,
      title_long: doc.css('#ctl00_cphVsebina_lblDolgNaziv').text.strip,
      registration_number: doc.css('#ctl00_cphVsebina_txtMaticna').text.strip,
      vat_exempt: doc.css('#ctl00_cphVsebina_txtZavezanec').text.strip == 'NE',
      bank_accounts: parse_bank_account(doc)
    }
  end
end
