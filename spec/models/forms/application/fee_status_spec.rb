require 'rails_helper'

RSpec.describe Forms::Application::FeeStatus do
  subject(:form_repository) { ApplicationFormRepository.new(application, fee_status) }

  params_list = [:date_received, :day_date_received, :month_date_received, :year_date_received,
                 :refund, :date_fee_paid, :day_date_fee_paid, :month_date_fee_paid, :year_date_fee_paid,
                 :discretion_applied, :discretion_manager_name, :discretion_reason, :calculation_scheme]

  let(:fee_status) { attributes_for(:detail) }
  let(:application) { build(:application) }
  let(:form_detail) { form_repository.application.detail }
  let(:form) { form_repository.process(:fee_status) }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  context 'before validation callbacks' do
    let(:date_received) { 1.day.ago.to_date }

    describe 'date applied' do
      before do
        fee_status.merge!({
                            day_date_received: date_received.day,
                            month_date_received: date_received.month,
                            year_date_received: date_received.year
                          })
        form
      end

      it 'saves the values to instance variable' do
        expect(form_detail.date_received.to_fs(:default)).to eq(date_received.to_fs(:default))
      end
    end

    describe 'reset discretion if no refund' do
      before do
        fee_status.merge!({
                            refund: false,
                            discretion_applied: true,
                            discretion_manager_name: 'test1',
                            discretion_reason: 'test2'
                          })
        form
      end

      it 'discretion is nil' do
        expect(form_detail.discretion_applied).to be_nil
        expect(form_detail.discretion_manager_name).to be_nil
        expect(form_detail.discretion_manager_name).to be_nil
      end
    end
  end

  describe 'validations' do
    before do
      fee_status.merge!({ refund: false, date_received: nil })
    end

    it 'invalidates the object' do
      expect(form.valid?).to be false
    end

    describe 'Date application received' do
      it_behaves_like 'date_received validation'
    end

    describe 'change to calculation_scheme_change' do
      before do
        received = FeatureSwitching::NEW_BAND_CALCUATIONS_ACTIVE_DATE - 1.day
        fee_status.merge!({ refund: false, date_received: received, calculation_scheme: 'scheme2' })
        allow(FeatureSwitching).to receive(:calculation_scheme).and_return :scheme1
        form.calculation_scheme = 'scheme2'
      end

      it 'invalidates the object' do
        travel_to(FeatureSwitching::NEW_BAND_CALCUATIONS_ACTIVE_DATE) do
          expect(form.valid?).to be false
          expect(form.errors.messages[:date_received]).to eq ["This date cannot be before the new legislation"]
        end
      end
    end

    describe 'no change to calculation_scheme_change' do
      before do
        fee_status.merge!({ refund: false, date_received: 1.day.ago, calculation_scheme: 'scheme1' })
        allow(FeatureSwitching).to receive(:calculation_scheme).and_return :scheme1
      end

      it 'invalidates the object' do
        expect(form.valid?).to be true
      end
    end

    describe 'store calculation_scheme' do
      before do
        fee_status.merge!({ refund: false, date_received: 1.day.ago })
        form
      end

      it 'invalidates the object' do
        expect(form_detail.calculation_scheme).not_to be_nil
      end
    end

    describe 'refund' do
      subject(:refund) do
        fee_status.merge!({
                            date_received: date_received.try(:to_fs, :db),
                            refund: refund_status,
                            date_fee_paid: date_fee_paid.try(:to_fs, :db)
                          })
        form
      end

      let(:current_time) { Time.zone.local(2014, 12, 1, 12, 30, 0) }
      let(:date_received) { Time.zone.local(2014, 11, 15, 12, 30, 0) }
      let(:date_fee_paid) { Time.zone.local(2014, 10, 15, 12, 30, 0) }
      let(:refund_status) { true }

      before { travel_to(current_time) }

      it { is_expected.to be_valid }

      describe 'when refund unchecked' do
        let(:date_fee_paid) { nil }
        let(:refund_status) { false }

        it { is_expected.to be_valid }

        context 'with date fee paid' do
          let(:date_fee_paid) { Time.zone.local(2014, 10, 15, 12, 30, 0) }
          it { is_expected.to be_valid }

          it 'reset date' do
            refund.valid?
            expect(refund.date_fee_paid).to be_nil
          end

        end
      end

      describe 'date fee paid' do
        describe 'range' do
          describe 'maximum boundary is 3 months before date_received' do
            describe 'just inside' do
              let(:date_fee_paid) { Time.zone.local(2014, 8, 16, 0, 10, 0) }

              it { is_expected.to be_valid }
            end

            describe 'on the same day' do
              let(:date_fee_paid) { Time.zone.local(2014, 11, 15, 12, 30, 0) }

              it { is_expected.to be_valid }
            end
          end

          describe 'minimum boundary is the date_received' do
            describe 'just inside' do
              let(:date_fee_paid) { Time.zone.local(2014, 11, 15, 8, 0, 0) }

              it { is_expected.to be_valid }
            end

            describe 'just outside' do
              let(:date_fee_paid) { Time.zone.local(2014, 11, 16, 13, 0, 0) }

              it { is_expected.not_to be_valid }

              it 'returns an error' do
                refund.valid?
                expect(refund.errors[:date_fee_paid]).to eq ['This date can’t be after the application was received']
              end
            end
          end

          describe 'and date received' do
            describe 'longer then 3 months' do
              let(:date_fee_paid) { Time.zone.local(2014, 1, 15, 8, 0, 0) }

              it { is_expected.not_to be_valid }

              it 'returns an error' do
                refund.valid?

                expect(refund.errors[:date_fee_paid]).to eq ['This fee was paid more than 3 months from the date received. Delivery Manager discretion must be applied to progress this application']
              end

              context 'discretion applied' do
                it 'false' do
                  refund.discretion_applied = false
                  expect(refund).not_to be_valid
                  expect(refund.errors[:discretion_applied]).to eq ['This application cannot be processed unless Delivery Manager discretion is applied']
                end

                it 'nil discretion' do
                  refund.discretion_applied = nil
                  expect(refund.errors[:date_fee_paid]).to eq ['This fee was paid more than 3 months from the date received. Delivery Manager discretion must be applied to progress this application']
                  expect(refund).not_to be_valid
                end

                context 'is granted' do
                  before { refund.discretion_applied = true }

                  it 'true' do
                    refund.discretion_reason = 'Dan'
                    refund.discretion_manager_name = 'Looks legit'
                    expect(refund).to be_valid
                  end

                  it 'true but no manager name' do
                    refund.discretion_reason = ''
                    refund.discretion_manager_name = 'Looks legit'

                    expect(refund).not_to be_valid
                  end

                  it 'true but no reason' do
                    refund.discretion_reason = 'Dan'
                    refund.discretion_manager_name = ''

                    expect(refund).not_to be_valid
                  end
                end
              end

              context 'date_fee_paid within limit and discretion reset' do
                let(:date_fee_paid) { Time.zone.local(2014, 11, 15, 8, 0, 0) }

                context 'discretion value set to nil' do
                  it 'when discretion_applied false' do
                    refund.discretion_applied = false
                    refund.valid?
                    expect(refund.discretion_applied).to be_nil
                  end

                  it 'when discretion_applied true' do
                    refund.discretion_applied = true
                    refund.valid?
                    expect(refund.discretion_applied).to be_nil
                  end

                  context 'when discretion_applied true' do
                    before {
                      refund.discretion_applied = true
                      refund.discretion_reason = 'Paperwork is fine'
                      refund.discretion_manager_name = 'Thompson'
                      refund.valid?
                    }
                    it { expect(refund.discretion_applied).to be_nil }
                    it { expect(refund.discretion_manager_name).to be_nil }
                    it { expect(refund.discretion_reason).to be_nil }
                  end
                end
              end
            end
          end
        end

        describe 'presence' do
          let(:date_fee_paid) { nil }
          let(:refund_status) { true }

          before { refund.valid? }

          context 'when date_received is set and is a valid date' do
            it 'sets an error on date_received field' do
              errors = refund.errors[:date_fee_paid]
              expect(errors).to include("Enter the date")
              expect(errors).to include("Enter the date in this format DD/MM/YYYY")
            end
          end
        end
      end
    end

  end

end
