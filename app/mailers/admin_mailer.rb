class AdminMailer < ActionMailer::Base
  ADMIN_EMAIL = 'miha@pozoj.si'
  default from: "revija@vzgojiteljica.si"

  def new_order order_id
    return unless @order = Order.find(order_id)
    mail(to: ADMIN_EMAIL, subject: "Novo naročilo ##{@order.id}")
  end
end
