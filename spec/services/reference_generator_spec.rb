require 'rails_helper'

RSpec.describe ReferenceGenerator, type: :service do
  let!(:office) { create :office }
  let!(:jurisdiction) { create :jurisdiction }
  let!(:business_entity) { create :business_entity, office: office, jurisdiction: jurisdiction, be_code: 'AB987', sop_code: '987654321' }

  subject(:generator) { described_class.new(application) }

  before { Settings.reference.date = '2016-06-30' }

  describe '#attributes' do
    context 'when the current date is before the new SOP reference date' do
      subject do
        Timecop.freeze(current_time) do
          generator.attributes
        end
      end

      let(:current_time) { Time.zone.parse(Settings.reference.date) - 1.day }
      let(:application) { create :application, office: office, jurisdiction: jurisdiction, business_entity: nil, reference: nil }

      context 'when there is no existing reference number for the same entity code' do
        it 'returns hash with the new reference' do
          expect(subject[:reference]).to eql('AB987-16-1')
        end
      end

      context 'when there is an existing reference number for the same entity code' do
        let(:existing_application1) { create :application, :processed_state, reference: 'AB987-16-18' }
        let(:existing_application2) { create :application, :processed_state, reference: 'AB987-16-19' }

        before do
          existing_application2
          existing_application1
          application
        end

        it 'returns hash with the reference next in sequence' do
          expect(subject[:reference]).to eql('AB987-16-20')
        end
      end

      context 'when there are two business entities for the same jurisdiction' do
        let!(:business_entity2) { create :business_entity, office: office, jurisdiction: jurisdiction, be_code: 'CB975', sop_code: '123456789' }
        before { business_entity.update_attribute(:valid_to, Time.zone.now) }

        it 'uses the active one' do
          expect(subject[:reference]).to eql('CB975-16-1')
        end
      end
    end

    context 'when the current date is after the new SOP reference date' do
      subject do
        Timecop.freeze(current_time) do
          generator.attributes
        end
      end

      let(:current_time) { Time.zone.parse(Settings.reference.date) }
      let(:application) { create :application, office: office, jurisdiction: jurisdiction, business_entity: nil, reference: nil }

      context 'when there is no existing reference number for the same entity code' do
        it 'returns hash with the new reference' do
          expect(subject[:reference]).to eql('PA16-000001')
        end
      end

      context 'when there is an existing reference number for the same entity code' do
        let(:existing_application1) { create :application, :processed_state, reference: 'PA16-000018' }
        let(:existing_application2) { create :application, :processed_state, reference: 'PA16-000019' }

        before do
          existing_application2
          existing_application1
          application
        end

        it 'returns hash with the reference next in sequence' do
          expect(subject[:reference]).to eql('PA16-000020')
        end
      end

      context 'when there are two business entities for the same jurisdiction' do
        let!(:business_entity2) { create :business_entity, office: office, jurisdiction: jurisdiction, be_code: 'CB975', sop_code: '123456789' }
        before { business_entity.update_attribute(:valid_to, Time.zone.now) }

        it 'it no-longer makes a difference' do
          expect(subject[:reference]).to eql('PA16-000001')
        end
      end
    end
  end
end
