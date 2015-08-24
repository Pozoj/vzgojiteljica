class Mailer < ActionMailer::Base
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
end
