require 'rspec'

describe UpdateMissingBusinessEntities do

  let(:business_entity) { create :business_entity }
  let(:shared_params) { { office: business_entity.office, jurisdiction: business_entity.jurisdiction } }
  let(:shared_params_with_business_entity) { { business_entity: business_entity, office: business_entity.office, jurisdiction: business_entity.jurisdiction } }

  before do
    create(:application_full_remission, :processed_state, shared_params)
    create(:application_full_remission, :processed_state, shared_params_with_business_entity)
    create(:application_full_remission, :processed_state, shared_params)
  end

  describe '#up!' do
    subject(:affected_records) { described_class.affected_records.size }

    describe 'before it is run' do
      it { is_expected.to eq 2 }
    end

    describe 'after it runs' do
      before { described_class.up! }

      it { is_expected.to eq 0 }
    end
  end
end
