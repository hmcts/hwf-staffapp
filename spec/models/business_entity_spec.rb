require 'rails_helper'

RSpec.describe BusinessEntity, type: :model do
  it { is_expected.to belong_to(:office) }
  it { is_expected.to belong_to(:jurisdiction) }

  it { is_expected.to validate_presence_of(:office) }
  it { is_expected.to validate_presence_of(:jurisdiction) }
  it { is_expected.to validate_presence_of(:be_code) }
  it { is_expected.to validate_presence_of(:sop_code) }
  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to respond_to(:valid_from) }
  it { is_expected.to respond_to(:valid_to) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:valid_from) }

    describe 'valid_to' do
      let(:business_entity) { build_stubbed :business_entity }

      before { business_entity.valid_from = Time.zone.today }

      subject { business_entity }

      context 'when valid_to is before valid_from' do
        before { business_entity.valid_to = Time.zone.yesterday }
        it { is_expected.to be_invalid }
      end
    end
  end

  context 'scopes' do
    let!(:hmcts)   { create(:office, name: 'HMCTS HQ Team ') }
    let!(:digital) { create(:office, name: 'Digital') }
    let!(:bristol) { create(:office, name: 'Bristol') }

    describe 'non_digital' do
      it 'excludes HQ business entities' do
        # each office gets 2 business_entities by default
        expect(described_class.count).to eql(6)
        expect(described_class.exclude_hq_teams.count).to eql(2)
      end

      it 'has the two bristol business entities' do
        all_codes = described_class.exclude_hq_teams.all.map(&:code)
        expect(all_codes).to match_array bristol.business_entities.map(&:code)
      end
    end
  end

  describe '#current_for' do
    let(:business_entity) { create :business_entity }
    subject { described_class.current_for(office, jurisdiction) }

    context 'when passed valid variables' do
      let(:office) { business_entity.office }
      let(:jurisdiction) { business_entity.jurisdiction }

      it { is_expected.to eq business_entity }
    end
  end
end
