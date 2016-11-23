class Mailer < ActionMailer::Base
  helper :entities

  ADMIN_EMAIL =  ENV['DEFAULT_ADMIN_EMAIL']
  EDITOR_EMAIL = ENV['DEFAULT_EDITOR_EMAIL']
  default from: ENV['DEFAULT_EMAIL_FROM']

  def customer_order_form_needed(customer_id)
    return unless @customer = Customer.find(customer_id)
    return unless @customer.billing_email
    mail(to: @customer.billing_email, subject: "Naročilnica za revijo Vzgojiteljica - #{@customer}")
  end

  def order_submitted(order_id)
    return unless @order = Order.find(order_id)
    mail(to: @order.email, subject: "Naročilo ##{@order.order_id} na revijo Vzgojiteljica sprejeto")
  end

  def inquiry_submitted(inquiry_id)
    return unless @inquiry = Inquiry.find(inquiry_id)
    return unless @inquiry.email?
    mail(to: @inquiry.email, subject: "Vprašanje ##{@inquiry.id} sprejeto")
  end

  def inquiry_answer(inquiry_id)
    return unless @inquiry = Inquiry.find(inquiry_id)
    return unless @inquiry.email?
    mail(to: @inquiry.email, subject: "Odgovor na vprašanje ##{@inquiry.id}")
  end

  def invoice_to_customer(invoice_id)
    return unless @invoice = Invoice.find(invoice_id)
    @customer = @invoice.customer
    email = @customer.billing_email
    return unless email.present?

    # To.
    recipient = "#{@customer.billing_name} <#{@customer.billing_email}>"

    # Attach invoice PDF.
    begin
      invoice_file = open(@invoice.pdf_idempotent)
      attachments["#{@invoice.receipt_id}.pdf"] = invoice_file.read

      mail(to: recipient, bcc: ADMIN_EMAIL, subject: "Račun #{@invoice.receipt_id} za revijo Vzgojiteljica")

      @invoice.events.create!(event: 'invoice_sent', details: recipient)
    rescue StandardError => e
      puts e.inspect
      @invoice.events.create!(event: 'invoice_send_error', details: e.inspect)
    end
  end

  def invoice_due_to_customer(invoice_id)
    return unless @invoice = Invoice.find(invoice_id)
    return unless @invoice.due?

    @customer = @invoice.customer
    email = @customer.billing_email
    return unless email.present?

    # To.
    recipient = "#{@customer.billing_name} <#{@customer.billing_email}>"

    # Attach invoice PDF.
    begin
      invoice_file = open(@invoice.pdf_idempotent)
      attachments["#{@invoice.receipt_id}.pdf"] = invoice_file.read

      mail(to: recipient, bcc: ADMIN_EMAIL, subject: "Opomin: Račun #{@invoice.receipt_id} za revijo Vzgojiteljica")

      @invoice.events.create!(event: 'invoice_due_sent', details: recipient)
    rescue StandardError => e
      puts e.inspect
      @invoice.events.create!(event: 'invoice_send_error', details: e.inspect)
    end
  end

  def invoices_due_to_customer(customer_id, invoice_ids)
    return unless @customer = Customer.find(customer_id)
    return unless @invoices = invoice_ids.map { |invoice_id| Invoice.find(invoice_id) }.compact
    @invoices = @invoices.find_all(&:due?)
    return unless @invoices.any?

    email = @customer.billing_email
    return unless email.present?

    # To.
    recipient = "#{@customer.billing_name} <#{@customer.billing_email}>"

    # Attach invoice PDFs.
    begin
      @invoices.each do |invoice|
        invoice_file = open(invoice.pdf_idempotent)
        attachments["#{invoice.receipt_id}.pdf"] = invoice_file.read
      end

      mail(to: recipient, bcc: ADMIN_EMAIL, subject: "Opomin: Računi za revijo Vzgojiteljica")

      @invoices.each { |invoice| invoice.events.create!(event: 'invoice_due_sent', details: recipient) }
    rescue StandardError => e
      puts e.inspect
      @invoices.each { |invoice| invoice.events.create!(event: 'invoice_send_error', details: e.inspect) }
    end
  end
end
