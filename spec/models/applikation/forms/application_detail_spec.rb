require 'rails_helper'

RSpec.describe Applikation::Forms::ApplicationDetail do
  params_list = %i[fee jurisdiction_id date_received probate date_of_death
                   deceased_name refund date_fee_paid form_name case_number
                   emergency emergency_reason]

  let(:detail) { attributes_for :detail }

  subject(:form) { described_class.new(detail) }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'when Detail object is passed in' do
    let(:detail) { build_stubbed(:complete_detail) }

    params_list.each do |attr_name|
      next if attr_name.equal?(:emergency)
      it "assigns #{attr_name}" do
        expect(form.send(attr_name)).to eq detail.send(attr_name)
      end
    end
  end

  describe 'when a Hash is passed in' do
    let(:detail) { attributes_for :complete_detail }

    params_list.each do |attr_name|
      it "assigns #{attr_name}" do
        expect(form.send(attr_name)).to eq detail[attr_name]
      end
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:fee) }
    it { is_expected.to validate_presence_of(:jurisdiction_id) }

    context 'when fee is blank' do
      let(:application_details) do
        params = { jurisdiction_id: 1, fee: nil }
        described_class.new(params)
      end

      it 'invalidates the object' do
        expect(application_details.valid?).to be false
      end
    end

    describe 'Date application received' do
      let(:application_details) do
        params = { jurisdiction_id: 1, fee: 500 }
        described_class.new(params)
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
        params = { jurisdiction_id: 1,
                   fee: 500,
                   date_received: Time.zone.yesterday,
                   probate: true,
                   deceased_name: 'Bob the builder',
                   date_of_death: Time.zone.yesterday }
        described_class.new(params)
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
        params = { jurisdiction_id: 1,
                   fee: 500,
                   date_received: Time.zone.yesterday,
                   refund: true,
                   date_fee_paid: Time.zone.yesterday }
        described_class.new(params)
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

    describe 'evidence_reason' do
      let(:reason) do
        params = { jurisdiction_id: 1,
                   fee: 500,
                   date_received: Time.zone.yesterday,
                   emergency: true,
                   emergency_reason: 'REASON' }
        described_class.new(params)
      end

      it 'has a valid factory build' do
        expect(reason).to be_valid
      end

      context 'emergency is true' do
        before do
          reason.emergency = false
          reason.emergency_reason = nil
        end

        it 'passes if emergency unchecked' do
          expect(reason.valid?).to eq true
        end
      end

      context 'emergency is false' do
        before do
          reason.emergency = true
          reason.emergency_reason = nil
        end

        it 'the reason is not filled in' do
          expect(reason.valid?).not_to eq true
        end
      end

      context 'is over 500 characters' do
        before { reason.emergency_reason = ('a' * 500).concat('1') }

        it 'is not valid' do
          expect(reason.valid?).to eq false
        end
      end
    end
  end

  describe '#save' do
    let(:jurisdiction) { build_stubbed(:jurisdiction) }
    let(:detail) { create :detail }
    subject(:form) { described_class.new(detail) }

    subject do
      form.update_attributes(params)
      form.save
    end

    context 'when attributes are correct' do
      let(:attributes) { attributes_for(:complete_detail, :probate, :refund, :emergency) }
      let(:params) { attributes.merge(jurisdiction_id: jurisdiction.id) }

      it { is_expected.to be true }

      before do
        subject
        detail.reload
      end

      it 'saves the parameters in the detail' do
        params.each do |key, value|
          expect(detail.send(key)).to eql(value)
        end
      end
    end

    context 'when attributes are incorrect' do
      let(:params) { { fee: '' } }

      it { is_expected.to be false }
    end
  end

  context 'instantiates at now' do
    Timecop.freeze(Time.zone.now - 1.day) do
      describe 'after 24 hours' do
        before do
          Timecop.travel(Time.zone.now + 2.day)
          detail.valid?
        end
        describe 'the detail should be valid' do
          let(:detail) { build_stubbed(:complete_detail) }
          it { is_expected.to be_valid  }
        end
      end
    end
  end
end
