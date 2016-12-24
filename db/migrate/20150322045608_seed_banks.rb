# frozen_string_literal: true
class SeedBanks < ActiveRecord::Migration
  def change
    Bank.destroy_all
    Bank.create([
                  {
                    name: 'ABANKA VIPA D.D.',
                    bic: 'ABANSI2X'
                  },
                  {
                    name: 'BANKA CELJE D.D.',
                    bic: 'SBCESI2X'
                  },
                  {
                    name: 'BANKA KOPER D.D.',
                    bic: 'BAKOSI2X'
                  },
                  {
                    name: 'BANKA SLOVENIJE',
                    bic: 'BSLJSI2X'
                  },
                  {
                    name: 'BANKA SPARKASSE D.D.',
                    bic: 'KSPKSI22'
                  },
                  {
                    name: 'BKS BANK AG, BANČNA PODRUŽNICA',
                    bic: 'BFKKSI22'
                  },
                  {
                    name: 'DELAVSKA HRANILNICA D.D.',
                    bic: 'HDELSI22'
                  },
                  {
                    name: 'DEŽELNA BANKA SLOVENIJE D.D.',
                    bic: 'SZKBSI2X'
                  },
                  {
                    name: 'FACTOR BANKA D.D.',
                    bic: 'FCTBSI2X'
                  },
                  {
                    name: 'GORENJSKA BANKA D.D., KRANJ',
                    bic: 'GORESI2X'
                  },
                  {
                    name: 'HRANILNICA IN POSOJILNICA VIPAVA D.D.',
                    bic: 'HKVISI22'
                  },
                  {
                    name: 'HRANILNICA LON D.D., KRANJ',
                    bic: 'HLONSI22'
                  },
                  {
                    name: 'HYPO-ALPE-ADRIA BANK D.D.',
                    bic: 'HAABSI22'
                  },
                  {
                    name: 'NOVA KREDITNA BANKA MARIBOR D.D.',
                    bic: 'KBMASI2X'
                  },
                  {
                    name: 'NOVA LJUBLJANSKA BANKA D.D.',
                    bic: 'LJBASI2X'
                  },
                  {
                    name: 'POŠTNA BANKA SLOVENIJE D.D.',
                    bic: 'PBSLSI22'
                  },
                  {
                    name: 'PROBANKA D.D.',
                    bic: 'PROBSI2X'
                  },
                  {
                    name: 'RAIFFEISEN BANKA D.D.',
                    bic: 'KREKSI22'
                  },
                  {
                    name: 'SBERBANK BANKA D.D.',
                    bic: 'SABRSI2X'
                  },
                  {
                    name: 'SKB BANKA D.D.',
                    bic: 'SKBASI2X'
                  },
                  {
                    name: 'UNICREDIT BANKA SLOVENIJA D.D.',
                    bic: 'BACXSI22'
                  },
                  {
                    name: 'ZVEZA BANK, PODRUŽNICA LJUBLJANA',
                    bic: 'VSGKSI22'
                  }
                ])
  end
end
