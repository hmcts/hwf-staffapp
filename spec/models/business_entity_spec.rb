require 'rails_helper'

RSpec.describe BusinessEntity, type: :model do
  it { is_expected.to belong_to(:office) }
  it { is_expected.to belong_to(:jurisdiction) }

  it { is_expected.to validate_presence_of(:office) }
  it { is_expected.to validate_presence_of(:jurisdiction) }
  it { is_expected.to validate_presence_of(:sop_code) }
  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to respond_to(:valid_from) }
  it { is_expected.to respond_to(:valid_to) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:valid_from) }

    describe 'valid_to' do
      subject { business_entity }

      let(:business_entity) { build_stubbed :business_entity }

      before { business_entity.valid_from = Time.zone.today }

      context 'when valid_to is before valid_from' do
        before { business_entity.valid_to = Time.zone.yesterday }
        it { is_expected.to be_invalid }
      end
    end

    describe 'sop_code' do
      subject { build :business_entity }
      it { is_expected.to validate_uniqueness_of(:sop_code).ignoring_case_sensitivity.scoped_to(:be_code) }
    end

    describe 'be_code' do
      before { Timecop.freeze(current_time) }
      after { Timecop.return }

      context 'before the BEC-SOP switchover date' do
        let(:current_time) { reference_change_date - 1.day }

        it { is_expected.to validate_presence_of(:be_code) }
      end

      context 'after the BEC-SOP switchover date' do
        let(:current_time) { reference_change_date }

        it { is_expected.not_to validate_presence_of(:be_code) }
      end
    end
  end

  context 'scopes' do
    before do
      create(:office, name: 'HMCTS HQ Team ')
      create(:office, name: 'Digital')
    end

    let!(:bristol) { create(:office, name: 'Bristol') }

    describe 'non_digital' do
      describe 'excludes HQ business entities' do
        # each office gets 2 business_entities by default
        it { expect(described_class.count).to eq 6 }
        it { expect(described_class.exclude_hq_teams.count).to eq 2 }
      end

      it 'has the two bristol business entities' do
        all_codes = described_class.exclude_hq_teams.all.map(&:code)
        expect(all_codes).to match_array bristol.business_entities.map(&:code)
      end
    end
  end

  describe '#current_for' do
    subject { described_class.current_for(office, jurisdiction) }

    let(:business_entity) { create :business_entity }

    context 'when passed valid variables' do
      let(:office) { business_entity.office }
      let(:jurisdiction) { business_entity.jurisdiction }

      it { is_expected.to eq business_entity }
    end
  end

  describe '#code' do
    subject do
      Timecop.freeze(current_time) do
        business_entity.code
      end
    end

    let(:business_entity) { build_stubbed :business_entity }

    context 'when called after the set date' do
      let(:current_time) { reference_change_date }

      it { is_expected.to eql business_entity.sop_code }
    end

    context 'when called before the set date' do
      let(:current_time) { reference_change_date - 1.day }

      it { is_expected.to eql business_entity.be_code }
    end
  end
end
