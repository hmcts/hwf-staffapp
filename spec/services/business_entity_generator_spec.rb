require 'rails_helper'

RSpec.describe BusinessEntityGenerator, type: :service do
  let(:current_time) { Time.zone.parse('2016-03-01 10:20:30') }
  let!(:office) { create :office }
  let!(:jurisdiction) { create :jurisdiction }
  let!(:business_entity) { create :business_entity, office: office, jurisdiction: jurisdiction, code: 'AB987' }

  subject(:generator) { described_class.new(application) }

  describe '#attributes' do
    let(:application) { create :application, office: office, jurisdiction: jurisdiction, business_entity: nil, reference: nil }

    subject do
      Timecop.freeze(current_time) do
        generator.attributes
      end
    end

    context 'when there is no existing reference number for the same entity code' do
      it 'returns hash with the relevant business entity' do
        expect(subject[:business_entity]).to eql(business_entity)
      end
    end

    context 'when there are two business entities for the same jurisdiction' do
      let!(:business_entity2) { create :business_entity, office: office, jurisdiction: jurisdiction, code: 'CB975' }
      before { business_entity.update_attribute(:valid_to, Time.zone.now) }

      it 'uses the active one' do
        expect(subject[:business_entity]).to eql(business_entity2)
      end
    end
  end
end
