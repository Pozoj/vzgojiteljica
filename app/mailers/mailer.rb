class Mailer < ActionMailer::Base
  default from:  ENV['DEFAULT_EMAIL_FROM']

  def order_submitted order_id
    return unless @order = Order.find(order_id)
    mail(to: @order.email, subject: "Naročilo ##{@order.order_id} na revijo Vzgojiteljica sprejeto")
  end
end
