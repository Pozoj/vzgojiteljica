# frozen_string_literal: true
class EInvoice
  ENTITY_TYPE_POZOJ = 'II'
  ENTITY_TYPE_CUSTOMER = 'BY'
  ENTITY_TYPE_RECEIVER = 'IV'

  attr_accessor :invoice

  def initialize(options = {})
    self.invoice = options[:invoice]
  end

  def generate
    Gyoku.xml(hash, key_converter: :camelcase)
  end

  def hash
    {
      Racun: {
        GlavaRacuna: invoice_head_hash,
        DatumiRacuna: invoice_date_hashes,
        Valuta: invoice_currency_hash,
        Lokacije: invoice_location_hash,
        PlacilniPogoji: invoice_payment_conditions_hash,
        PodatkiPodjetja: entity_hashes,
        PostavkeRacuna: invoice_line_item_hashes,
        PovzetekDavkovRacuna: invoice_tax_hash,
        PoljubnoBesedilo: [
          invoice_vat_exempt_hash,
          invoice_payment_shoutout_hash,
          invoice_invoicer_hash,
          invoice_foot_hash
        ],
        PovzetekZneskovRacuna: invoice_sum_hash,
        ReferencniDokumenti: reference_documents_hash
      }
    }
  end

  def entity_hash(entity, entity_type)
    # Order is important here:
    #
    # <xs:sequence>
    #   <xs:element ref="NazivNaslovPodjetja"/>
    #   <xs:element ref="FinancniPodatkiPodjetja" minOccurs="0" maxOccurs="unbounded"/>
    #   <xs:element ref="ReferencniPodatkiPodjetja" maxOccurs="unbounded"/>
    #   <xs:element ref="KontaktiPodjetja" minOccurs="0" maxOccurs="unbounded"/>
    # </xs:sequence>

    hash = {
      NazivNaslovPodjetja: {
        VrstaPartnerja: entity_type,
        NazivPartnerja: split_text(text: entity.title, key_name: 'NazivPartnerja', segment_length: 35),
        Ulica: {
          Ulica1: entity.address
        },
        Kraj: entity.post.name,
        NazivDrzave: 'Slovenija',
        PostnaStevilka: entity.post.id,
        KodaDrzave: 'SI'
      }
    }

    # Append bank hash if present.
    bank_hash = entity_bank_hash(entity)
    hash.merge!(bank_hash) if bank_hash

    hash[:ReferencniPodatkiPodjetja] = entity_reference_numbers_hash(entity)

    # Append contacts hash if this is POZOJ.
    if entity_type == ENTITY_TYPE_POZOJ
      contacts_hash = entity_contacts_hash(entity)
      hash.merge!(contacts_hash) if contacts_hash
    end

    hash
  end

  # <ReferencniDokumenti VrstaDokumenta="ON">
  # <StevilkaDokumenta>NAR-2012-512</StevilkaDokumenta>
  # <DatumDokumenta>2012-02-25T00:00:00</DatumDokumenta>
  def reference_documents_hash
    if invoice.order_form
      order_form_hash = { StevilkaDokumenta: invoice.order_form }
      if invoice.order_form_date
        order_form_hash.merge(DatumDokumenta: invoice.order_form_date.to_datetime.beginning_of_day)
      end
    else
      subscription = invoice.customer.subscriptions.active.last
      return [] unless subscription

      order_form_hash = { StevilkaDokumenta: "Naročnina #{subscription.created_at.year}-#{subscription.id}" }
    end

    {
      :@VrstaDokumenta => 'ON', :content! => order_form_hash
    }
  end

  def entity_contacts_hash(entity)
    contacts = {}

    if entity.email?
      contacts[:Komunikacije] ||= []
      contacts[:Komunikacije] << {
        StevilkaKomunikacije: entity.email,
        VrstaKomunikacije: 'EM'
      }
    end

    if entity.phone?
      contacts[:Komunikacije] ||= []
      contacts[:Komunikacije] << {
        StevilkaKomunikacije: entity.phone,
        VrstaKomunikacije: 'TE'
      }
    end

    if entity.try(:contact_person)
      contacts[:KontaktnaOseba] = {
        ImeOsebe: entity.try(:contact_person).try(:name)
      }
    end

    return unless contacts.any?
    { KontaktiPodjetja: contacts }
  end

  def entity_reference_numbers_hash(entity)
    reference_numbers = [
      {
        VrstaPodatkaPodjetja: 'VA',
        PodatekPodjetja: entity.vat_id_formatted
      }
    ]

    # Append registration number hash if present.
    if entity.registration_number?
      reference_numbers << {
        VrstaPodatkaPodjetja: 'GN',
        PodatekPodjetja: entity.registration_number
      }
    end

    # Append internal customer ID unless this is POZOJ.
    unless entity.pozoj?
      reference_numbers << {
        VrstaPodatkaPodjetja: 'IT',
        PodatekPodjetja: entity.id
      }
    end

    reference_numbers
  end

  # Commenting out this one, because it's supposedly invalid?!?
  def entity_bank_hash(entity)
    return if !entity.bank || !entity.account_number?
    {
      FinancniPodatkiPodjetja: {
        BancniRacun: {
          StevilkaBancnegaRacuna: entity.account_number,
          NazivBanke1: entity.bank.name,
          BIC: entity.bank.bic_elongated
        }
      }
    }
  end

  def entity_hashes
    [pozoj_hash] + customer_hashes
  end

  def pozoj_hash
    entity_hash(Entity.pozoj, ENTITY_TYPE_POZOJ)
  end

  def customer_hashes
    [
      customer_hash(ENTITY_TYPE_CUSTOMER),
      customer_hash(ENTITY_TYPE_RECEIVER)
    ]
  end

  def customer_hash(entity_type = ENTITY_TYPE_CUSTOMER)
    entity_hash(invoice.customer, entity_type)
  end

  def invoice_head_hash
    {
      VrstaRacuna: 380,
      StevilkaRacuna: invoice.receipt_id,
      FunkcijaRacuna: 9,
      NacinPlacila: 0,
      KodaNamena: 'SUBS'
    }
  end

  def invoice_currency_hash
    {
      VrstaValuteRacuna: 2,
      KodaValute: 'EUR'
    }
  end

  def invoice_location_hash
    {
      VrstaLokacije: 91,
      NazivLokacije: 'Velenje'
    }
  end

  def invoice_date_hashes
    [
      {
        VrstaDatuma: 137,
        DatumRacuna: invoice.created_at.to_datetime.beginning_of_day
      },
      {
        VrstaDatuma: 35,
        DatumRacuna: invoice.created_at.to_datetime.beginning_of_day
      },
      # NEED TO IMPLEMENT FROM TO for INVOICES
      {
        VrstaDatuma: 263,
        DatumRacuna: invoice.created_at.to_datetime.beginning_of_day
      },
      {
        VrstaDatuma: 263,
        DatumRacuna: invoice.created_at.to_datetime.beginning_of_day
      }
    ]
  end

  def invoice_payment_conditions_hash
    {
      PodatkiORokih: {
        VrstaPogoja: 3
      },
      PlacilniRoki: {
        VrstaDatumaPlacilnegaRoka: 13,
        Datum: invoice.due_at.to_datetime.beginning_of_day
      }
    }
  end

  def invoice_line_item_hashes
    invoice.line_items.map do |li|
      {
        "Postavka/": '',
        OpisiArtiklov: [
          {
            KodaOpisaArtikla: 'F',
            OpisArtikla: split_text(text: li.product, segment_length: 35, key_name: 'OpisArtikla')
          },
          {
            OpisArtikla: {
              OpisArtikla1: 'OZNAKA_POSTAVKE',
              OpisArtikla2: 'navadna'
            }
          }
        ],
        KolicinaArtikla: {
          VrstaKolicine: 47,
          Kolicina: li.quantity,
          EnotaMere: li.unit_eancom
        },
        ZneskiPostavke: [
          # Koncni znesek
          {
            VrstaZneskaPostavke: 38,
            ZnesekPostavke: li.total.to_f
          },
          # Znesek s popustom
          {
            VrstaZneskaPostavke: 52,
            ZnesekPostavke: li.subtotal.to_f
          },
          # Obdavcljivi znesek
          {
            VrstaZneskaPostavke: 125,
            ZnesekPostavke: li.subtotal.to_f
          },
          # Vrednost
          {
            VrstaZneskaPostavke: 203,
            ZnesekPostavke: li.subtotal.to_f
          }
        ],
        CenaPostavke: {
          Cena: li.price_per_item_with_discount.to_f
        },
        DavkiPostavke: {
          # Stopnja DDV
          DavkiNaPostavki: {
            VrstaDavkaPostavke: 'VAT',
            OdstotekDavkaPostavke: li.tax_percent
          },
          ZneskiDavkovPostavke: [
            # Osnova za DDV
            {
              VrstaZneskaDavkaPostavke: 125,
              Znesek: li.subtotal.to_f
            },
            # Znesek DDV
            {
              VrstaZneskaDavkaPostavke: 124,
              Znesek: li.tax.to_f
            }
          ]
        },
        OdstotkiPostavk: {
          Identifikator: 'A',
          VrstaOdstotkaPostavke: 1,
          OdstotekPostavke: li.discount_percent || 0,
          VrstaZneskaOdstotka: 204,
          ZnesekOdstotka: 0
        }
      }
    end
  end

  def invoice_tax_hash
    {
      DavkiRacuna: {
        VrstaDavka: 'VAT',
        OdstotekDavka: invoice.tax_percent
      },
      ZneskiDavkov: [
        # Osnova za DDV
        {
          VrstaZneskaDavka: 125,
          ZnesekDavka: invoice.subtotal.to_f
        },
        # Znesek DDV
        {
          VrstaZneskaDavka: 124,
          ZnesekDavka: invoice.tax.to_f
        }
      ]
    }
  end

  def invoice_sum_hash
    [
      {
        # Vsota vrednosti postavk brez popustov
        ZneskiRacuna: {
          VrstaZneska: 79,
          ZnesekRacuna: invoice.subtotal.to_f
        },
        SklicZaPlacilo: {
          SklicPlacila: 'PQ'
        }
      },
      {
        # Vsota zneskov popustov
        ZneskiRacuna: {
          VrstaZneska: 53,
          ZnesekRacuna: 0
        },
        SklicZaPlacilo: {
          SklicPlacila: 'PQ'
        }
      },
      {
        # Vsota osnov za DDV
        ZneskiRacuna: {
          VrstaZneska: 125,
          ZnesekRacuna: invoice.subtotal.to_f
        },
        SklicZaPlacilo: {
          SklicPlacila: 'PQ'
        }
      },
      {
        # Vsota zneskov DDV
        ZneskiRacuna: {
          VrstaZneska: 176,
          ZnesekRacuna: invoice.tax.to_f
        },
        SklicZaPlacilo: {
          SklicPlacila: 'PQ'
        }
      },
      {
        # Vsota vrednosti postavk s popusti in DDV
        ZneskiRacuna: {
          VrstaZneska: 86,
          ZnesekRacuna: invoice.total.to_f
        },
        SklicZaPlacilo: {
          SklicPlacila: 'PQ'
        }
      },
      {
        # Znesek za placilo
        ZneskiRacuna: {
          VrstaZneska: 9,
          ZnesekRacuna: invoice.total.to_f
        },
        SklicZaPlacilo: {
          SklicPlacila: 'PQ',
          StevilkaSklica: invoice.payment_id_full
        }
      }
    ]
  end

  def invoice_payment_shoutout_hash
    text_hash(
      text_type: 'GLAVA_TEKST',
      text: "Račun plačajte na TRR: #{Entity.pozoj.account_number_formatted}, odprt pri #{Entity.pozoj.bank} Pri plačilu računa se sklicujte na: #{invoice.payment_id}. Po izteku roka za plačilo zaračunavamo zakonske zamudne obresti. Reklamacije upoštevamo, če so podane v 7 dneh od izstavitve računa."
    )
  end

  def invoice_foot_hash
    text_hash(
      text_type: 'NOGA_TEKST',
      text: Entity.pozoj.string_description
    )
  end

  def invoice_invoicer_hash
    text_hash(
      text_type: 'FAKTURIST',
      text: 'Darja Slapničar'
    )
  end

  def invoice_vat_exempt_hash
    text_hash(
      type: 'TXD',
      text_type: 'DAVCNI_TEKST',
      text: 'DDV ni obračunan po 1. točki 94. člena ZDDV.'
    )
  end

  def text_hash(type: 'AAI', text_type: nil, text:, max_length: 280, segment_length: 70, key_name: 'Tekst')
    raise 'Text too long.' if text.length > max_length

    {
      VrstaBesedila: type,
      Besedilo: split_text(text_type: text_type, text: text, segment_length: segment_length, key_name: key_name)
    }
  end

  def split_text(text_type: nil, text:, segment_length: 70, key_name: 'Tekst')
    texts = {}
    index = 1

    if text_type
      texts = { "#{key_name}1" => text_type }
      index = 2
    end

    texts = text.chars.each_slice(segment_length).each_with_object(texts) do |segment, hash|
      hash["#{key_name}#{index}"] = segment.join
      index += 1
      hash
    end
  end
end
