# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Invoice do
  subject { build_stubbed :invoice }

  it { should be_valid }

  it 'should generate receipt_id' do
    invoice = build(:invoice)
    invoice.year = 2016
    invoice.reference_number = 12_312
    invoice.save
    expect(invoice.receipt_id).to eq('12312-2016')
  end

  it 'should automatically assign year' do
    invoice = create(:invoice)
    expect(invoice.year).to eq(Date.today.year)
  end
end
