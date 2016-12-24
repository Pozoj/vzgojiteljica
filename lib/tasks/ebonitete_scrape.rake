# frozen_string_literal: true
namespace :ebonitete do
  task scrape: :environment do
    customers = Customer.not_person.where(account_number: nil).to_a
    customers = customers.shuffle
    puts "Starting EBoniteteScraper for #{customers.count} customers without bank accounts"

    customers.each do |customer|
      unless customer.vat_id
        puts "VAT ID MISSING ALERT ALERT #{customer.id} - #{customer}"
        next
      end
      puts "Starting to search data for #{customer} (#{customer.vat_id})"

      scraper = EboniteteScraper.new(customer.vat_id)
      data = scraper.parse

      unless data
        puts 'NOT FOUND ON EBONITETE'
        next
      end

      unless strip_bank(customer.title) == strip_bank(data[:title_long])
        if Levenshtein.normalized_distance(strip_bank(customer.title), strip_bank(data[:title_long])) > 0.6
          customer.title = data[:title_long]
        else
          puts "Skipping name change #{customer.title} > #{data[:title_long]}"
        end
      end
      customer.registration_number = data[:registration_number]
      customer.vat_exempt = data[:vat_exempt]
      data[:bank_accounts].each do |account|
        if b = find_bank(account[:bank])
          b = Bank.where(bic: b[:bic]).first
          customer.bank = b
          customer.account_number = account[:account_number]
          break
        end
        puts "ERROR FINDING BANK FOR: #{data[:bank_accounts].inspect}"
      end
      puts customer.changes.inspect
      if customer.valid?
        customer.save!
      else
        puts "ERRORS ERRORS: #{customer.errors}"
      end
      wait_time = rand(15) + 1
      puts
      puts "Waiting #{wait_time}s"
      puts
      sleep wait_time
    end
  end

  def find_bank(bank)
    bank = strip_bank(bank)
    banks.each do |b|
      return b if strip_bank(b[:name]).match(Regexp.new(bank))
      next unless b[:aliases].any?
      b[:aliases].each do |a|
        return b if bank.match(Regexp.new(strip_bank(a)))
      end
    end

    nil
  end

  def strip_bank(bank_string)
    return '' unless bank_string
    bank_string.downcase.gsub('d.d.', '').gsub(/[^a-zA-Z]/, '')
  end

  def banks
    [
      {
        name: 'ABANKA VIPA D.D.',
        aliases: ['ABANKA'],
        bic: 'ABANSI2X'
      },
      {
        name: 'BANKA CELJE D.D.',
        aliases: ['CELJE'],
        bic: 'SBCESI2X'
      },
      {
        name: 'BANKA KOPER D.D.',
        aliases: ['KOPER'],
        bic: 'BAKOSI2X'
      },
      {
        name: 'BANKA SLOVENIJE',
        aliases: [],
        bic: 'BSLJSI2X'
      },
      {
        name: 'BANKA SPARKASSE D.D.',
        aliases: ['SPARKASSE'],
        bic: 'KSPKSI22'
      },
      {
        name: 'BKS BANK AG, BANČNA PODRUŽNICA',
        aliases: ['BKS'],
        bic: 'BFKKSI22'
      },
      {
        name: 'DELAVSKA HRANILNICA D.D.',
        aliases: ['DH'],
        bic: 'HDELSI22'
      },
      {
        name: 'DEŽELNA BANKA SLOVENIJE D.D.',
        aliases: ['DBS'],
        bic: 'SZKBSI2X'
      },
      {
        name: 'FACTOR BANKA D.D.',
        aliases: ['FACTOR'],
        bic: 'FCTBSI2X'
      },
      {
        name: 'GORENJSKA BANKA D.D.',
        aliases: %w(GORENJSKA GB),
        bic: 'GORESI2X'
      },
      {
        name: 'HRANILNICA IN POSOJILNICA VIPAVA D.D.',
        aliases: [],
        bic: 'HKVISI22'
      },
      {
        name: 'HRANILNICA LON D.D., KRANJ',
        aliases: ['LON'],
        bic: 'HLONSI22'
      },
      {
        name: 'HYPO-ALPE-ADRIA BANK D.D.',
        aliases: ['HYPO'],
        bic: 'HAABSI22'
      },
      {
        name: 'NOVA KREDITNA BANKA MARIBOR D.D.',
        aliases: ['NKBM'],
        bic: 'KBMASI2X'
      },
      {
        name: 'NOVA LJUBLJANSKA BANKA D.D.',
        aliases: ['NLB'],
        bic: 'LJBASI2X'
      },
      {
        name: 'POŠTNA BANKA SLOVENIJE D.D.',
        aliases: ['PBS'],
        bic: 'PBSLSI22'
      },
      {
        name: 'PROBANKA D.D.',
        aliases: ['PROBANKA'],
        bic: 'PROBSI2X'
      },
      {
        name: 'RAIFFEISEN BANKA D.D.',
        aliases: ['RAIFFEISEN'],
        bic: 'KREKSI22'
      },
      {
        name: 'SBERBANK BANKA D.D.',
        aliases: ['SBERBANK'],
        bic: 'SABRSI2X'
      },
      {
        name: 'SKB BANKA D.D.',
        aliases: ['SKB'],
        bic: 'SKBASI2X'
      },
      {
        name: 'UNICREDIT BANKA SLOVENIJA D.D.',
        aliases: ['UNICREDIT'],
        bic: 'BACXSI22'
      },
      {
        name: 'ZVEZA BANK, PODRUŽNICA LJUBLJANA',
        aliases: ['ZVEZA BANK'],
        bic: 'VSGKSI22'
      }
    ]
  end
end
