RSpec.describe UserHelper do

  let(:user) { build :user, jurisdiction_id: nil }

  describe '#jurisdiction_name' do
    it { expect(helper.jurisdiction_name(user)).to eq('No main jurisdiction') }

    context 'county jurisdiction' do
      let(:jurisdiction) { build(:jurisdiction, name: 'county') }
      let(:user) { build :user, jurisdiction: jurisdiction }

      it { expect(helper.jurisdiction_name(user)).to eq('county') }
    end
  end
end
