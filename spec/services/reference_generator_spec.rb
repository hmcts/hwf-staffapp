require 'rails_helper'

RSpec.describe ReferenceGenerator, type: :service do
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

      it 'returns hash with the new reference' do
        expect(subject[:reference]).to eql('AB987-16-1')
      end
    end

    context 'when there is an existing reference number for the same entity code' do
      let!(:existing_application) { create :application, :processed_state, reference: 'AB987-16-19' }

      it 'returns hash with the relevant business entity' do
        expect(subject[:business_entity]).to eql(business_entity)
      end

      it 'returns hash with the reference next in sequence' do
        expect(subject[:reference]).to eql('AB987-16-20')
      end
    end
  end
end
