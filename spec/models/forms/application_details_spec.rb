require 'rails_helper'

RSpec.describe Forms::ApplicationDetails do
  PARAMS_LIST = %i[fee jurisdiction_id date_received probate date_of_death deceased_name refund date_fee_paid]

  let(:application) { create :application }

  subject { described_class.new(application) }

  describe 'PERMITTED_ATTRIBUTES' do
    it 'returns a list of attributes' do
      expect(described_class::PERMITTED_ATTRIBUTES).to match_array(PARAMS_LIST)
    end
  end

  describe 'when Application object is passed in' do
    let(:form) { described_class.new(application) }

    PARAMS_LIST.each do |attr_name|
      it "assigns #{attr_name}" do
        expect(form.send(attr_name)).to eq application.send(attr_name)
      end
    end
  end

  describe 'when a Hash is passed in' do
    let(:hash) { application.attributes }
    let(:form) { described_class.new(hash) }

    PARAMS_LIST.each do |attr_name|
      it "assigns #{attr_name}" do
        expect(form.send(attr_name)).to eq hash[attr_name.to_s]
      end
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

    describe 'probate' do
      let(:probate) do
        described_class.new({ jurisdiction_id: 1,
                              fee: 500,
                              date_received: Time.zone.yesterday,
                              probate: true,
                              deceased_name: 'Bob the builder',
                              date_of_death: Time.zone.yesterday })
      end

      it 'has a valid factory build' do
        expect(probate).to be_valid
      end

      it 'passes if probate unchecked' do
        probate.probate = false
        probate.deceased_name = nil
        expect(probate).to be_valid
      end

      describe 'requires' do
        describe 'date of death' do
          describe 'presence' do
            before do
              probate.date_of_death = nil
              probate.valid?
            end

            it 'must be entered' do
              expect(probate).to be_invalid
            end

            it 'returns an error if missing' do
              expect(probate.errors[:date_of_death]).to eq ['Enter the date in this format 01/01/2015']
            end
          end

          describe 'range' do
            it 'must be prior to today' do
              probate.date_of_death = Time.zone.tomorrow
              expect(probate).to be_invalid
            end
          end
        end

        describe 'deceased name' do
          before do
            probate.deceased_name = nil
            probate.valid?
          end

          it 'must be entered' do
            expect(probate).to be_invalid
          end

          it 'returns an error if missing' do
            expect(probate.errors[:deceased_name]).to eq ["The deceased's name should be entered"]
          end
        end
      end
    end

    describe 'refund' do
      let(:refund) do
        described_class.new({ jurisdiction_id: 1,
                              fee: 500,
                              date_received: Time.zone.yesterday,
                              refund: true,
                              date_fee_paid: Time.zone.yesterday })
      end

      it 'has a valid factory build' do
        expect(refund).to be_valid
      end

      it 'passes if refund unchecked' do
        refund.refund = false
        refund.date_fee_paid = nil
        expect(refund).to be_valid
      end
      describe 'date fee paid' do
        describe 'range' do
          it 'allows between today and 3 months ago' do
            refund.date_fee_paid = Time.zone.today
            expect(refund).to be_valid
          end

          describe 'maximum' do
            before do
              refund.date_fee_paid = Time.zone.today.-3.months.+1.day
              refund.valid?
            end

            it 'is 3 months' do
              expect(refund).to be_invalid
            end

            it 'returns an error if exceeded' do
              expect(refund.errors[:date_fee_paid]).to eq ['The application must have been made in the last 3 months']
            end
          end

          describe 'minimum' do
            before do
              refund.date_fee_paid = Time.zone.tomorrow
              refund.valid?
            end

            it 'is today' do
              expect(refund).to be_invalid
            end

            it 'returns an error if too low' do
              expect(refund.errors[:date_fee_paid]).to eq ['The application cannot be a future date']
            end
          end
        end

        describe 'presence' do
          before do
            refund.date_fee_paid = nil
            refund.valid?
          end

          it 'is required' do
            expect(refund).to be_invalid
          end
          it 'returns an error if missing' do
            expect(refund.errors[:date_fee_paid]).to eq ['Enter the date in this format 01/01/2015']
          end
        end
      end
    end
  end
end
