require 'rails_helper'
require 'pry'

describe Subscription do
  subject { create :subscription }

  it { should be_valid }
end
