require 'rails_helper'

describe Subscriber do
  subject! { create :subscriber }

  it { should be_valid }
  it { should be_inactive }
  it { should_not be_active }

  it 'should be marked as active is it has an active subscription' do
    subscription = create(:subscription, subscriber: subject)
    subject.subscriptions << subscription
    expect(subject).to be_active

    expect(Subscriber.count).to eq(1)
    expect(Subscriber.active.to_a.count).to eq(1)
    expect(Subscriber.inactive.to_a.count).to eq(0)
  end

  it 'should be marked as active if it has at least one active subscription' do
    active_subscription = create(:subscription, subscriber: subject)
    subject.subscriptions << active_subscription
    inactive_subscriptions = create(:subscription, :inactive, subscriber: subject)
    subject.subscriptions << inactive_subscriptions
    expect(subject).to be_active
    expect(subject).not_to be_inactive
  end

  it 'should be found in the database as active if it has at least one active subscription' do
    active_subscription = create(:subscription, subscriber: subject)
    subject.subscriptions << active_subscription
    inactive_subscriptions = create(:subscription, :inactive, subscriber: subject)
    subject.subscriptions << inactive_subscriptions

    expect(Subscriber.count).to eq(1)
    expect(Subscriber.active.to_a.count).to eq(1)
    expect(Subscriber.inactive.to_a.count).to eq(0)
  end

  it 'should be found in the database as inactive if it has all subscription inactive' do
    inactive_subscriptions = create(:subscription, :inactive, subscriber: subject)
    subject.subscriptions << inactive_subscriptions

    expect(Subscriber.count).to eq(1)
    expect(Subscriber.active.to_a.count).to eq(0)
    expect(Subscriber.inactive.to_a.count).to eq(1)
  end
end
