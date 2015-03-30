class EEnvelope
  UJP_BIC = 'UJPLSI2DICL'

  attr_accessor :invoice

  def initialize options = {}
    self.invoice = options[:invoice]
  end

  def generate
    Gyoku.xml(hash,
      :key_converter => :none,
      :attributes! => {
        envelope: {
          'xsi:noNamespaceSchemaLocation' => 'icl_eb_envelope_einvoice.xsd'
        }
      }
    )  
  end

  def hash
    {
      timestamp: DateTime.now,
      envelope: {
        sender: sender_hash,
        receiver: receiver_hash,
        doc_data: doc_data_hash,
        payment_data: payment_data_hash,
        attachments: attachments_hashes,
      }
    }
  end

  def sender_hash
    # <sender>
    #   <name>POZOJ, DARJA SLAPNIÈAR S.P.</name>
    #   <country>SI</country>
    #   <address>PIREŠICA 2</address>
    #   <address>3320 VELENJE</address>
    #   <sender_identifier>78459575</sender_identifier>
    #   <sender_eddress>
    #     <sender_agent>HAABSI22XXX</sender_agent>
    #     <sender_mailbox>SI56330000006887185</sender_mailbox>
    #   </sender_eddress>
    #   <phone />
    # </sender>
    pozoj = Entity.pozoj

    {
      name: pozoj.to_s,
      country: 'SI',
      address: [
        pozoj.address,
        pozoj.post.to_s
      ],
      sender_identifier: pozoj.vat_id_formatted,
      sender_eddress: {
        sender_agent: pozoj.bank.bic_elongated,
        sender_mailbox: pozoj.account_number
      },
      email_id: pozoj.email
    }
  end

  def receiver_hash
    # <receiver>
    #   <name>DIJAŠKI DOM MARIBOR</name>
    #   <country>SI</country>
    #   <address>GOSPOSVETSKA 89</address>
    #   <address>2000 MARIBOR</address>
    #   <receiver_identifier>SI39583953</receiver_identifier>
    #   <receiver_eddress>
    #     <receiver_agent>UJPLSI2DICL</receiver_agent>
    #     <receiver_mailbox>SI56011006030631168</receiver_mailbox>
    #   </receiver_eddress>
    # </receiver>
    entity = invoice.customer

    {
      name: entity.to_s,
      country: 'SI',
      address: [
        entity.address,
        entity.post.to_s
      ],
      receiver_identifier: entity.vat_id_formatted,
      receiver_eddress: {
        receiver_agent: UJP_BIC,
        receiver_mailbox: entity.account_number
      }
    }
  end

  def doc_data_hash
    # <doc_data>
    #   <doc_type>0002</doc_type>
    #   <doc_type_ver>01</doc_type_ver> 
    #   <external_doc_id>1-2015</external_doc_id>
    #   <timestamp>2015-03-29T17:45:12.000</timestamp>
    # </doc_data>

    {
      doc_type: '0002',
      doc_type_ver: '01',
      external_doc_id: invoice.invoice_id,
      timestamp: DateTime.now
    }
  end

  def payment_data_hash
    # <payment_data>
    #   <payment_method>0</payment_method>
    #   <creditor>
    #     <name>POZOJ, DARJA SLAPNIÈAR S.P.</name>
    #     <country>SI</country>
    #     <address>PIREŠICA 2</address>
    #     <address>3320 VELENJE</address>
    #     <identification />
    #     <creditor_agent>HAABSI22XXX</creditor_agent>
    #     <creditor_account>SI56330000006887185</creditor_account>
    #   </creditor>
    #   <debtor>
    #     <name>Dijaški Dom Maribor</name>
    #     <country>SI</country>
    #     <address>Gosposvetska 89</address>
    #     <address>2000 Maribor</address>
    #     <identification />
    #     <debtor_agent>BSLJSI2XXXX</debtor_agent>
    #     <debtor_account>SI56011006030631168</debtor_account>
    #   </debtor>
    #   <requested_execution_date>2015-04-22</requested_execution_date>
    #   <amount>34.8</amount>
    #   <currency>EUR</currency>
    #   <remittance_information>
    #     <creditor_structured_reference>SI001084-1-2015</creditor_structured_reference>
    #     <additional_remittance_information>Placilo racuna: 1-2015</additional_remittance_information>
    #   </remittance_information>
    #   <purpose>SUBS</purpose>
    # </payment_data>
    pozoj = Entity.pozoj
    entity = invoice.customer

    {
      payment_method: 0,
      creditor: {
        name: pozoj.to_s,
        country: 'SI',
        address: [
          pozoj.address,
          pozoj.post.to_s
        ],
        creditor_agent: pozoj.bank.bic_elongated,
        creditor_account: pozoj.account_number
      },
      debtor: {
        name: entity.to_s,
        country: 'SI',
        address: [
          entity.address,
          entity.post.to_s
        ],
        debtor_agent: entity.bank.bic_elongated,
        debtor_account: entity.account_number
      },
      requested_execution_date: invoice.due_at.strftime('%Y-%m-%d'),
      amount: invoice.total.to_f,
      currency: 'EUR',
      remittance_information: {
        creditor_structured_reference: invoice.payment_id_full,
        additional_remittance_information: "Placilo racuna: #{invoice.payment_id}"
      },
      purpose: 'SUBS'
    }
  end

  def attachments_hashes
    # <attachments>
    #   <count>3</count>
    #   <attachment>
    #     <filename>12015_1_1-2015.xml</filename>
    #     <type>xml</type>
    #     <description>Racun v e-Slog XML obliki</description>
    #   </attachment>
    #   <attachment>
    #     <filename>12015_2_1-2015.pdf</filename>
    #     <type>pdf</type>
    #     <description>vizualizacija</description>
    #   </attachment>
    #   <attachment>
    #     <filename>12015_3_obvestilo.pdf</filename>
    #     <type>pdf</type>
    #     <description>dopis</description>
    #   </attachment>
    # </attachments>

    {
      count: 3,
      attachment: [
        {
          filename: "#{invoice.invoice_id}.xml",
          type: 'xml',
          description: 'Racun v e-Slog XML obliki'
        },
        {
          filename: "#{invoice.invoice_id}.pdf",
          type: 'pdf',
          description: 'Vizualizacija v PDF obliki'
        },
        {
          filename: "obvestilo.pdf",
          type: 'pdf',
          description: 'Obvestilo o racunu'
        },
      ]
    }
  end
end