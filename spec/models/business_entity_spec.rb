require 'rails_helper'

RSpec.describe BusinessEntity do
  it { is_expected.to belong_to(:office) }
  it { is_expected.to belong_to(:jurisdiction) }

  it { is_expected.to validate_presence_of(:sop_code) }
  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to respond_to(:valid_from) }
  it { is_expected.to respond_to(:valid_to) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:valid_from) }

    describe 'valid_to' do
      subject { business_entity }

      let(:business_entity) { build_stubbed(:business_entity) }

      before { business_entity.valid_from = Time.zone.today }

      context 'when valid_to is before valid_from' do
        before { business_entity.valid_to = Time.zone.yesterday }
        it { is_expected.to be_invalid }
      end
    end

    describe 'sop_code valid in context' do
      subject(:business_entity) { create(:business_entity) }
      let(:business_entity_2) { create(:business_entity, sop_code: business_entity.sop_code) }

      it "of office_id and name" do
        business_entity_2.office_id = business_entity.office_id
        business_entity_2.name = business_entity.name
        expect(business_entity_2).not_to be_valid
      end

      it "of office_id" do
        business_entity_2.office_id = business_entity.office_id
        business_entity_2.name = 'Newcastle Court of Protection'
        expect(business_entity_2).to be_valid
      end

      it "of name" do
        business_entity_2.office_id = business_entity.office_id + 1
        business_entity_2.name = business_entity.name
        expect(business_entity_2).to be_valid
      end
    end
  end

  context 'scopes' do
    before do
      hmcts = create(:office, name: 'HMCTS HQ Team ')
      create(:business_entity, office: hmcts)
      digital = create(:office, name: 'Digital')
      create(:business_entity, office: digital)
    end

    let!(:bristol) { create(:office, name: 'Bristol', business_entities: [business_entity]) }
    let(:business_entity) { create(:business_entity) }

    describe 'non_digital' do
      describe 'excludes HQ business entities' do
        it { expect(described_class.count).to eq 3 }
        it { expect(described_class.exclude_hq_teams.count).to eq 1 }
      end

      it 'has the bristol business entity' do
        all_codes = described_class.exclude_hq_teams.all.map(&:code)
        expect(all_codes).to match_array bristol.business_entities.map(&:code)
      end
    end
  end

  describe '#current_for' do
    subject { described_class.current_for(office, jurisdiction) }

    let(:business_entity) { create(:business_entity) }

    context 'when passed valid variables' do
      let(:office) { business_entity.office }
      let(:jurisdiction) { business_entity.jurisdiction }

      it { is_expected.to eq business_entity }
    end
  end

  describe '#code' do
    subject do
      business_entity.code
    end

    let(:business_entity) { build_stubbed(:business_entity) }

    context 'when called after the set date' do
      it { is_expected.to eql business_entity.sop_code }
    end
  end
end
