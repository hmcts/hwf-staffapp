require 'rails_helper'

RSpec.describe OfficeJurisdiction, type: :model do
  subject { described_class.new office: create(:office), jurisdiction: create(:jurisdiction) }

  it 'passes factory build' do
    expect(subject).to be_valid
  end

  describe 'relationships' do
    it { is_expected.to respond_to :office }
    it { is_expected.to respond_to :jurisdiction }
  end
end
