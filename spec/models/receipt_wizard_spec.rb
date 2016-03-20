require 'rails_helper'

RSpec.describe ReceiptWizard do
  subject { ReceiptWizard.new(type: :invoice) }

  describe 'model' do
    it 'should return correct model based on type' do
      subject.type = :invoice
      expect(subject.model).to eq(Invoice)
      subject.type = :offer
      expect(subject.model).to eq(Offer)
    end
  end

  describe 'reference_number' do
    it 'should return 0 by default' do
      expect(subject.reference_number).to eq(0)
    end

    it 'should just return last receipt number if present' do
      subject.last_receipt_number = 100
      expect(subject.reference_number).to eq(100)
    end

    it 'should return last model record for the current year number if present' do
      subject.type = :invoice
      create(:invoice, reference_number: 200, year: Date.today.year)
      expect(subject.reference_number).to eq(200)
    end

    it 'should return 0 if models are not in the current year' do
      subject.type = :invoice
      create(:invoice, reference_number: 200, year: 1998)
      expect(subject.reference_number).to eq(0)
    end
  end

  describe 'next_reference_number' do
    it 'should start at 1 and continue' do
      expect(subject.next_reference_number).to eq(1)
      expect(subject.next_reference_number).to eq(2)
      expect(subject.next_reference_number).to eq(3)
    end

    it 'should start at last receipt number and continue' do
      subject.last_receipt_number = 15
      expect(subject.next_reference_number).to eq(16)
      expect(subject.next_reference_number).to eq(17)
      expect(subject.next_reference_number).to eq(18)
    end
  end

  describe 'build_receipt' do
    it 'should build a receipt for a customer' do
      customer = build_stubbed(:customer)
      receipt = subject.build_receipt(customer: customer)
      expect(receipt.reference_number).to eq(1)
      expect(receipt.customer).to eq(customer)
    end
  end

  describe 'build_line_item_for_subscription' do
    it 'should build a line item for subscription' do
      subscription = build_stubbed(:subscription, quantity: 5, discount: 5)
      subscription.plan = build_stubbed(:plan, price_cents: 5000)
      subscription.subscriber = build_stubbed(:subscriber, name: 'Lorem')

      line_item = subject.build_line_item_for_subscription(subscription)
      expect(line_item.entity_name).to eq('Lorem')
      expect(line_item.price_per_item).to eq(50)
      expect(line_item.discount_percent).to eq(5)
      expect(line_item.quantity).to eq(5)
    end
  end
end
