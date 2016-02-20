require 'rails_helper'

describe Order do
  subject { create :order }

  it { should be_valid }

  it 'created an order form on creation' do
    expect(subject.order_form).to_not be_nil
    expect(subject.order_form.form_id).to eq("Naročilo ##{subject.id}")
  end
end
