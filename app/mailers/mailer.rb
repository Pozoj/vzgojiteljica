class Mailer < ActionMailer::Base
  ADMIN_EMAIL =  ENV['DEFAULT_ADMIN_EMAIL']
  EDITOR_EMAIL = ENV['DEFAULT_EDITOR_EMAIL']
  default from: ENV['DEFAULT_EMAIL_FROM']

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
    invoice_file = open(@invoice.pdf_idempotent)
    attachments["#{@invoice.invoice_id}.pdf"] = invoice_file.read

    @invoice.events.create!(event: 'invoice_sent', details: recipient)

    mail(to: recipient, bcc: ADMIN_EMAIL, subject: "Račun #{@invoice.invoice_id} za revijo Vzgojiteljica")
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
    invoice_file = open(@invoice.pdf_idempotent)
    attachments["#{@invoice.invoice_id}.pdf"] = invoice_file.read

    @invoice.events.create!(event: 'invoice_due_sent', details: recipient)

    mail(to: recipient, bcc: ADMIN_EMAIL, subject: "Opomin: Račun #{@invoice.invoice_id} za revijo Vzgojiteljica")
  end
end
