require 'rails_helper'

RSpec.describe Forms::ApplicationDetails do
  PARAMS_LIST = %i[fee jurisdiction_id date_received]

  subject { described_class.new }

  describe 'PERMITTED_ATTRIBUTES' do
    it 'returns a list of attributes' do
      expect(described_class::PERMITTED_ATTRIBUTES).to match_array(PARAMS_LIST)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:fee) }
    it { is_expected.to validate_presence_of(:jurisdiction_id) }

    context 'when fee is blank' do
      let(:application_details) do
        params = { jurisdiction_id: 1, fee: nil }
        Forms::ApplicationDetails.new(params)
      end

      it 'invalidates the object' do
        expect(application_details.valid?).to be false
      end
    end

    describe 'Date application received' do
      let(:application_details) do
        described_class.new({ jurisdiction_id: 1, fee: 500 })
      end

      describe 'presence' do
        before do
          application_details.date_received = nil
          application_details.valid?
        end

        it 'is required' do
          expect(application_details).to be_invalid
        end

        it 'returns an error message, if omitted' do
          expect(application_details.errors[:date_received]).to eq ['Enter the date in this format 01/01/2015']
        end
      end

      describe 'range' do
        it 'allows between today and 3 months ago' do
          application_details.date_received = Time.zone.today
          expect(application_details).to be_valid
        end

        describe 'maximum' do
          before do
            application_details.date_received = Time.zone.today.-3.months.+1.day
            application_details.valid?
          end

          it 'is 3 months' do
            expect(application_details).to be_invalid
          end

          it 'returns an error if exceeded' do
            expect(application_details.errors[:date_received]).to eq ['The application must have been made in the last 3 months']
          end
        end

        describe 'minimum' do
          before do
            application_details.date_received = Time.zone.tomorrow
            application_details.valid?
          end

          it 'is today' do
            expect(application_details).to be_invalid
          end

          it 'returns an error if too low' do
            expect(application_details.errors[:date_received]).to eq ['The application cannot be a future date']
          end
        end
      end
    end
  end

end
