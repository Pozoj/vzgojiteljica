# frozen_string_literal: true
require 'rails_helper'

RSpec.describe OrderForm do
  subject { create :order_form }

  it { should be_valid }

  describe '#processed!' do
    it 'marks order_form as processed by setting the processed_at date' do
      expect(subject).to_not be_processed
      subject.processed!
      expect(subject).to be_processed
      expect(subject.processed_at).to_not be_nil
    end
  end

  describe '#able_to_process_attach?' do
    it 'when there are active subscriptions all without order forms' do
      customer = create(:customer)
      subscriber = create(:subscriber, customer: customer)
      create(:subscription, order_form: nil, subscriber: subscriber)
      create(:subscription, order_form: nil, subscriber: subscriber)
      create(:subscription, order_form: nil, subscriber: subscriber, end: 1.month.ago)
      subject.customer = customer

      expect(subject).to be_able_to_process_attach
    end

    it 'not when there are active subscriptions and one has order form' do
      customer = create(:customer)
      subscriber = create(:subscriber, customer: customer)
      create(:subscription, order_form: subject, subscriber: subscriber)
      subject.customer = customer

      expect(subject).to_not be_able_to_process_attach
    end
  end

  describe '#process_attach!' do
    it 'should attach itself to customers active subscriptions' do
      customer = create(:customer)
      subscriber = create(:subscriber, customer: customer)
      plan = create(:plan)
      subscription_1 = create(:subscription, plan: plan, order_form: nil, subscriber: subscriber)
      subscription_2 = create(:subscription, plan: plan, order_form: nil, subscriber: subscriber)
      subscription_3 = create(:subscription, plan: plan, order_form: nil, subscriber: subscriber, end: 1.month.ago)
      subject.customer = customer

      expect do
        subject.process_attach!
      end.to_not change(Subscription, :count)

      expect(subject).to be_processed

      expect(subscription_1.reload.order_form).to eq(subject)
      expect(subscription_2.reload.order_form).to eq(subject)
      expect(subscription_3.reload.order_form).to be_nil

      # Correctly associated
      expect(subject.reload.subscriptions.count).to eq(2)
    end
  end

  describe '#able_to_process_renew?' do
    it 'not when there are active subscriptions with order forms' do
      customer = create(:customer)
      subscriber = create(:subscriber, customer: customer)
      create(:subscription, order_form: nil, subscriber: subscriber)
      create(:subscription, order_form: nil, subscriber: subscriber)
      create(:subscription, order_form: nil, subscriber: subscriber, end: 1.month.ago)
      subject.customer = customer

      expect(subject).to_not be_able_to_process_renew
    end

    it 'when there are active subscriptions with order forms' do
      old_order_form = create(:order_form, year: 1999)
      customer = create(:customer)
      subscriber = create(:subscriber, customer: customer)
      create(:subscription, order_form: old_order_form, subscriber: subscriber)
      create(:subscription, order_form: old_order_form, subscriber: subscriber)
      subject.customer = customer

      expect(subject).to be_able_to_process_renew
    end

    it 'not when there are active subscriptions with this order form' do
      customer = create(:customer)
      subscriber = create(:subscriber, customer: customer)
      create(:subscription, order_form: subject, subscriber: subscriber)
      create(:subscription, order_form: subject, subscriber: subscriber)
      subject.customer = customer

      expect(subject).to_not be_able_to_process_renew
    end
  end

  describe '#process_renew!' do
    it 'should create new subscriptions if order form for last year exists' do
      old_order_form = create(:order_form, year: 2013)
      customer = create(:customer)
      subscriber = create(:subscriber, customer: customer)
      subscription_1 = create(:subscription, quantity: 1, order_form: old_order_form, subscriber: subscriber)
      subscription_2 = create(:subscription, quantity: 11, order_form: old_order_form, subscriber: subscriber)
      subscription_3 = create(:subscription, quantity: 50, end: 1.month.ago, order_form: old_order_form, subscriber: subscriber)

      subject.start = Date.parse('1/1/2016')
      subject.end = Date.parse('31/12/2016')
      subject.customer = customer

      expect do
        subject.process_renew!
      end.to change(Subscription, :count).by(1)

      expect(subject).to be_processed
      expect(subscription_1.reload.order_form).to eq(old_order_form)
      expect(subscription_1).to_not be_active
      expect(subscription_2.reload.order_form).to eq(old_order_form)
      expect(subscription_2).to_not be_active
      expect(subscription_3.reload.order_form).to eq(old_order_form)

      new_subscription = subject.reload.subscriptions.first

      expect(new_subscription.quantity).to eq(12)
      expect(new_subscription.subscriber).to eq(subscription_1.subscriber)
      expect(new_subscription.start).to eq(Date.parse('1/1/2016'))
      expect(new_subscription.end).to eq(Date.parse('31/12/2016'))
      expect(new_subscription.plan).to eq(subscription_1.plan)
      expect(new_subscription.order_form).to eq(subject)
    end
  end
end
