require 'rails_helper'

RSpec.describe Receipt do
  subject { build_stubbed :receipt }

  it { should be_valid }
end
