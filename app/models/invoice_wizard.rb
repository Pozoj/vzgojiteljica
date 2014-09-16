class InvoiceWizard
  include ActiveModel::Model
  attr_accessor :issue_id
  attr_accessor :last_invoice_number

  def process!
    reference_number = last_invoice_number.to_i
    Subscription.active.each do |s|
      unless s.plan
        puts s
        next
      end
      next if s.plan.free?
      next if s.plan.billing_frequency < 6
      reference_number += 1
      
      i = Invoice.new
      i.reference_number = reference_number
      i.subscription = s
      i.issue_id = issue_id
      i.due_at = 30.days.from_now
      i.subtotal = (s.quantity or 1) * s.plan.price
      i.save
    end
  end
end
