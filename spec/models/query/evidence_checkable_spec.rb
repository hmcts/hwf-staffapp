require 'rails_helper'

RSpec.describe Query::EvidenceCheckable do
  describe '.find_all' do
    subject { described_class.new.find_all }

    let!(:application_1) { create(:application_part_remission) }
    let!(:application_2) { create(:application_full_remission) }
    let(:application_3) { create(:application_no_remission) }
    let!(:emergency_application) { create(:application_full_remission, emergency_reason: 'REASON') }

    it 'includes only part and full remission applications' do
      is_expected.to match_array([application_1, application_2])
    end

    it 'does not include emergency applications' do
      is_expected.not_to include emergency_application
    end

  end

  context 'list' do
    let(:benefit_application) { create(:application, benefits: true) }

    before do
      full_outcome_1
      full_outcome_2
      part_outcome_1
      part_outcome_2
      benefit_application
    end

    context 'refund' do
      let(:full_outcome_1) { create(:application_full_remission, :refund) }
      let(:full_outcome_2) { create(:application_full_remission, :refund) }
      let(:part_outcome_1) { create(:application_part_remission, :refund) }
      let(:part_outcome_2) { create(:application_part_remission) }

      it 'limits applications count to frequency' do
        application = create(:application_full_remission, :refund)
        create(:application_full_remission, :refund)

        expect(described_class.new.list(application.id, true, 2)).to eq([full_outcome_2, part_outcome_1])
      end
    end

    context 'non refund' do
      let(:full_outcome_1) { create(:application_full_remission) }
      let(:full_outcome_2) { create(:application_full_remission) }
      let(:part_outcome_1) { create(:application_part_remission) }
      let(:part_outcome_2) { create(:application_part_remission, :refund) }

      it 'limits applications count to frequency' do
        application = create(:application_full_remission)
        create(:application_full_remission, :refund)
        list = described_class.new.list(application.id, false, 2)
        expect(list).to eq([full_outcome_2, part_outcome_1])
        list = described_class.new.list(application.id, false, 3)
        expect(list).to eq([full_outcome_1, full_outcome_2, part_outcome_1])
      end
    end

  end
end
