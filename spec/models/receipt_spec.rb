# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Receipt do
  subject { build_stubbed :receipt }

  it { should be_valid }

  describe 'order_form=' do
    let(:order_form) { build_stubbed(:order_form, form_id: 'Nar 2015/1', issued_at: Date.parse('1/1/2016')) }

    it 'should set the underlying string as well as date' do
      subject.order_form = order_form
      expect(subject.order_form).to eq('Nar 2015/1')
      expect(subject.order_form_date).to eq(Date.parse('1/1/2016'))
    end

    it 'should support just setting a string, thus leaving the date out' do
      subject.order_form = 'Nar VZG-1'
      expect(subject.order_form).to eq('Nar VZG-1')
      expect(subject.order_form_date).to eq(nil)

      subject.order_form_date = Date.parse('1/1/2009')
      expect(subject.order_form_date).to eq(Date.parse('1/1/2009'))
    end

    it 'should handle sets of nil and nullify both fields' do
      subject.order_form = 'Talekova Narocilnica'
      expect(subject.order_form).to eq('Talekova Narocilnica')
      expect(subject.order_form_date).to be_nil

      subject.order_form = nil
      expect(subject.order_form).to be_nil
      expect(subject.order_form_date).to be_nil
    end
  end
end
