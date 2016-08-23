require 'rspec'

describe UpdateMissingBusinessEntities do

  subject { described_class }

  let(:business_entity) { create :business_entity }
  let(:shared_params) { { office: business_entity.office, jurisdiction: business_entity.jurisdiction } }
  let(:shared_params_with_business_entity) { { business_entity: business_entity, office: business_entity.office, jurisdiction: business_entity.jurisdiction } }
  let!(:application1) { create(:application_full_remission, :processed_state, shared_params) }
  let!(:application2) { create(:application_full_remission, :processed_state, shared_params_with_business_entity) }
  let!(:application3) { create(:application_full_remission, :processed_state, shared_params) }

  describe '#up!' do
    it 'works in sequence' do
      expect(subject.affected_records.size).to eql(2)
      subject.up!
      expect(subject.affected_records.size).to eql(0)
    end
  end

end
