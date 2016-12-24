# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Subscription do
  let!(:plan) { create :plan, billing_frequency: 6, price: 10 }
  subject! { create :subscription }

  it { should be_valid }
  it { should be_active }
  it { should_not be_inactive }

  it 'should validate that start is before the end' do
    subject.end = subject.start - 1.day
    expect(subject).to_not be_valid
  end

  it 'should be active if today is the end day' do
    subject.end = Date.today
    expect(subject).to be_active
  end

  it 'should be active if no end date' do
    subject.end = nil
    expect(subject).to be_active
  end

  it 'should not be active if end day was 2 days ago' do
    subject.end = 2.days.ago
    expect(subject).to_not be_active
    expect(subject).to be_inactive
  end

  context 'database scopes' do
    it 'should find the active subscription' do
      expect(Subscription.count).to eq(1)
      expect(Subscription.active.count).to eq(1)
      expect(Subscription.inactive.count).to eq(0)
    end

    it 'should not find the active subscription if the end day was 2 days ago' do
      subject.end = 2.days.ago
      subject.save
      expect(Subscription.active.count).to eq(0)
      expect(Subscription.inactive.count).to eq(1)
    end
  end

  describe '#new_from_order' do
    it 'creates a new subscription from an order' do
      order = create(:order,
                     title: 'Talibaum d.o.o.',
                     name: 'Salibassim Naranissim',
                     address: 'Tontoronto 16a',
                     post_id: 3320,
                     quantity: 2,
                     plan_type: 6)

      subscriber = subject.subscriber

      subscription = nil
      expect do
        subscription = Subscription.new_from_order(subscriber: subscriber, order: order)
      end.to change(Subscription, :count).by(1)

      expect(subscription).to be_active
      expect(subscription.plan.billing_frequency).to eq(6)
      expect(subscription.start).to eq(Date.today)
      expect(subscription.order_form).to eq(order.order_form)
      expect(subscription.quantity).to eq(order.quantity)
      expect(subscription.subscriber).to eq(subscriber)

      expect(order.order_form.customer).to eq(subscriber.customer)
    end
  end
end
