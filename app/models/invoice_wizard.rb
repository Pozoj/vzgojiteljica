class InvoiceWizard
  include ActiveModel::Model
  attr_accessor :issue_id
  attr_accessor :last_invoice_number

  def process!
    reference_number = last_invoice_number.to_i
    Customer.all.each do |c|
      next unless c.subscriptions.active.any?
      
      i = Invoice.new
      i.reference_number = reference_number
      i.customer = c
      i.issue_id = issue_id
      i.due_at = 30.days.from_now
      
      c.subscriptions.active.each do |s|
        unless s.plan
          puts s
          next
        end

        next if s.plan.free?
        next if s.plan.billing_frequency < 6
        
        li = i.line_items.build
        li.entity_name = s.subscriber.to_s
        li.product = "Vzgojiteljica #{i.issue}"
        li.quantity = s.quantity
        li.unit = 'kom'
        li.price_per_item = s.plan.price
        li.discount_percent = 0
        li.price_per_item_with_discount = s.plan.price
      end
      
      i.line_items.each(&:calculate)
      i.calculate_totals
      
      next if i.subtotal === 0.00 # Skip if invoice 0.

      i.save!
      
      reference_number += 1
    end
  end
end
