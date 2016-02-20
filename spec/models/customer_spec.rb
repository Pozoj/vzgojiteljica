require 'rails_helper'

describe Customer do
  let!(:plan) { create :plan, billing_frequency: 6, price: 10 }
  subject { create :customer }

  it { should be_valid }

  describe '#new_from_order' do
    it 'creates a new one from an order' do
      order = create(:order,
        title: 'Talibaum d.o.o.',
        name: 'Salibassim Naranissim',
        address: 'Tontoronto 16a',
        post_id: 3320,
        quantity: 2,
        plan_type: 6
      )

      customer = nil
      expect {
        expect {
          expect {
            customer = Customer.new_from_order(order: order)
          }.to change(Customer, :count).by(1)
        }.to change(Subscriber, :count).by(1)
      }.to change(Subscription, :count).by(1)

      expect(customer.name).to eq('Salibassim Naranissim')
      expect(customer.title).to eq('Talibaum d.o.o.')
      expect(customer.address).to eq('Tontoronto 16a')

      subscriber = customer.subscribers.first
      expect(subscriber.name).to eq('Salibassim Naranissim')
      expect(subscriber.title).to eq('Talibaum d.o.o.')

      subscription = subscriber.subscriptions.first
      expect(subscription).to be_active
      expect(subscription.plan.billing_frequency).to eq(6)

      order_form = order.order_form
      expect(order_form.customer).to eq(customer)
    end
  end
end
