# frozen_string_literal: true
class AddDataToBanks < ActiveRecord::Migration
  def change
    add_column :banks, :address, :string
    add_column :banks, :post_id, :integer
    add_column :banks, :account_number, :string

    [{
      bic: 'ABANSI2X',
      address: 'SLOVENSKA 58',
      post_id: '1517 LJUBLJANA',
      account_number: 'SI56010000000500021'
    },
     {
       bic: 'SBCESI2X',
       address: 'VODNIKOVA 2',
       post_id: '3000 CELJE',
       account_number: 'SI56010000000600028'
     },
     {
       bic: 'BAKOSI2X',
       address: 'PRISTANIŠKA 14',
       post_id: '6502 KOPER',
       account_number: 'SI56010000001000153'
     },
     {
       bic: 'KSPKSI22',
       address: 'CESTA V KLEČE 15',
       post_id: '1000 LJUBLJANA',
       account_number: 'SI56010000003400030'
     },
     {
       bic: 'BFKKSI22',
       address: 'DUNAJSKA 161',
       post_id: '1000 LJUBLJANA',
       account_number: 'SI56010000003500134'
     },
     {
       bic: 'HDELSI22',
       address: 'MIKLOŠIČEVA 5',
       post_id: '1000 LJUBLJANA',
       account_number: 'SI56010000006100025'
     },
     {
       bic: 'SZKBSI2X',
       address: 'KOLODVORSKA 9',
       post_id: '1000 LJUBLJANA',
       account_number: 'SI56010000001910013'
     },
     {
       bic: 'GORESI2X',
       address: 'BLEIWEISOVA 1',
       post_id: '4000 KRANJ',
       account_number: 'SI56010000000700035'
     },
     {
       bic: 'HKVISI22',
       address: 'GLAVNI TRG 15',
       post_id: '5271 VIPAVA',
       account_number: 'SI56010000006400046'
     },
     {
       bic: 'HLONSI22',
       address: 'BLEIWEISOVA 2',
       post_id: '4000 KRANJ',
       account_number: 'SI56010000006000018'
     },
     {
       bic: 'HAABSI22',
       address: 'DUNAJSKA 117',
       post_id: '1000 LJUBLJANA',
       account_number: 'SI56010000003300023'
     },
     {
       name: 'KDD-KLIRINŠKO DEPOTNA DRUŽBA D.D.',
       address: 'TIVOLSKA 48',
       post_id: '1000 LJUBLJANA',
       account_number: 'SI56010000007900054'
     },
     {
       bic: 'KBMASI2X',
       address: 'ULICA VITA KRAIGHERJA 4',
       post_id: '2505 MARIBOR',
       account_number: 'SI56010000000400014'
     },
     {
       bic: 'LJBASI2X',
       address: 'TRG REPUBLIKE 2',
       post_id: '1520 LJUBLJANA',
       account_number: 'SI56010000000200097'
     },
     {
       bic: 'PBSLSI22',
       address: 'ULICA VITA KRAIGHERJA 5',
       post_id: '2000 MARIBOR',
       account_number: 'SI56010000009000034'
     },
     {
       bic: 'KREKSI22',
       address: 'ZAGREBŠKA CESTA 76',
       post_id: '2000 MARIBOR',
       account_number: 'SI56010000002400057'
     },
     {
       bic: 'SABRSI2X',
       address: 'DUNAJSKA 128A',
       post_id: '1101 LJUBLJANA',
       account_number: 'SI56010000003029005'
     },
     {
       name: 'SID BANKA D.D.',
       address: 'JOSIPINE TURNOGRAJSKE 6',
       post_id: '1000 LJUBLJANA',
       account_number: 'SI56010000003800058'
     },
     {
       bic: 'SKBASI2X',
       address: 'AJDOVŠČINA 4',
       post_id: '1513 LJUBLJANA',
       account_number: 'SI56010000000300007'
     },
     {
       bic: 'BACXSI22',
       address: 'ŠMARTINSKA 140',
       post_id: '1000 LJUBLJANA',
       account_number: 'SI56010000002900092'
     },
     {
       bic: 'VSGKSI22',
       address: 'BRAVNIČARJEVA 13',
       post_id: '1000 LJUBLJANA',
       account_number: 'SI56010000003700051'
     }].each do |bank|
      next unless bank[:bic]
      b = Bank.find_by(bic: bank[:bic])
      b.address = bank[:address]
      b.post_id = bank[:post_id]
      b.account_number = bank[:account_number]
      b.save
      puts b.inspect
    end
  end
end
