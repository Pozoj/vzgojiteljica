require 'rails_helper'

describe OrderForm do
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
end
