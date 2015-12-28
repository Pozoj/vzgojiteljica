require 'rails_helper'

describe Subscription do
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
end
