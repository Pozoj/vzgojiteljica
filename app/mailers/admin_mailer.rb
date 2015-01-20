class AdminMailer < ActionMailer::Base
  ADMIN_EMAIL =  ENV['DEFAULT_ADMIN_EMAIL']
  EDITOR_EMAIL = ENV['DEFAULT_EDITOR_EMAIL']
  default from:  ENV['DEFAULT_EMAIL_FROM']

  def new_order order_id
    return unless @order = Order.find(order_id)
    mail(to: ADMIN_EMAIL, subject: "Novo naročilo ##{@order.id}")
  end
end
