require 'rails_helper'

RSpec.describe OfficeJurisdiction, type: :model do
  subject { described_class.new office: create(:office), jurisdiction: create(:jurisdiction) }

  it { is_expected.to be_valid }
  it { is_expected.to respond_to :office }
  it { is_expected.to respond_to :jurisdiction }
end
