class AdminMailer < ActionMailer::Base
  ADMIN_EMAIL =  ENV['DEFAULT_ADMIN_EMAIL']
  EDITOR_EMAIL = ENV['DEFAULT_EDITOR_EMAIL']
  default from:  ENV['DEFAULT_EMAIL_FROM']

  def new_order(order_id)
    return unless @order = Order.find(order_id)
    mail(to: ADMIN_EMAIL, subject: "Novo naročilo ##{@order.order_id}")
  end

  def new_inquiry(inquiry_id)
    return unless @inquiry = Inquiry.find(inquiry_id)
    mail(to: ADMIN_EMAIL, cc: EDITOR_EMAIL, subject: "Novo vprašanje ##{@inquiry.id}: #{@inquiry.subject}")
  end

  def invoices_due
    @invoices = Invoice.due.unpaid.unreversed
    return unless @invoices.any?
    mail(to: ADMIN_EMAIL, subject: "Zapadli računi na dan #{Date.today.to_s} - #{@invoices.count} računov")
  end
end
