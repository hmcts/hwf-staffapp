require 'rails_helper'

RSpec.describe Forms::Application::FeeStatus do
  subject(:form) { described_class.new(fee_status) }

  params_list = [:date_received, :day_date_received, :month_date_received, :year_date_received,
                 :refund, :date_fee_paid, :day_date_fee_paid, :month_date_fee_paid, :year_date_fee_paid,
                 :discretion_applied, :discretion_manager_name, :discretion_reason]

  let(:fee_status) { attributes_for(:detail) }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  context 'before validation callbacks' do
    describe 'date applied' do
      before do
        form.day_date_received = 1
        form.month_date_received = 2
        form.year_date_received = 2019
        form.valid?
      end

      it 'saves the values to instance variable' do
        expect(form.date_received.to_fs(:default)).to eq('01/02/2019')
      end
    end
  end

  # describe 'when Detail object is passed in' do
  #   let(:detail) { build_stubbed(:complete_detail) }

  #   params_list.each do |attr_name|
  #     next if /day|month|year|emergency/.match?(attr_name.to_s)
  #     it "assigns #{attr_name}" do
  #       expect(form.send(attr_name)).to eq detail.send(attr_name)
  #     end
  #   end
  # end

  # describe 'when a Hash is passed in' do
  #   let(:detail) { attributes_for(:complete_detail) }

  #   params_list.each do |attr_name|
  #     next if /day|month|year|emergency/.match?(attr_name.to_s)

  #     it "assigns #{attr_name}" do
  #       expect(form.send(attr_name)).to eq detail[attr_name]
  #     end
  #   end
  # end

  describe 'validations' do
    let(:application_details) do
      params = { refund: false, date_received: nil }
      described_class.new(params)
    end

    it 'invalidates the object' do
      expect(application_details.valid?).to be false
    end

    describe 'Date application received' do
      let(:application_details) do
        params = { refund: false }
        described_class.new(params)
      end

      include_examples 'date_received validation' do
        let(:form) { application_details }
      end
    end

    describe 'refund' do
      subject(:refund) do
        params = { jurisdiction_id: 1,
                   fee: 500,
                   date_received: date_received.try(:to_fs, :db),
                   refund: refund_status,
                   date_fee_paid: date_fee_paid.try(:to_fs, :db),
                   form_name: 'ABC123' }
        described_class.new(params)
      end

      let(:current_time) { Time.zone.local(2014, 12, 1, 12, 30, 0) }
      let(:date_received) { Time.zone.local(2014, 11, 15, 12, 30, 0) }
      let(:date_fee_paid) { Time.zone.local(2014, 10, 15, 12, 30, 0) }
      let(:refund_status) { true }

      before { Timecop.freeze(current_time) }
      after { Timecop.return }

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
                  expect(refund).to be_valid
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

                it 'nil' do
                  refund.discretion_applied = nil
                  expect(refund).not_to be_valid
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

          before { refund.valid? }

          context 'when date_received is set and is a valid date' do
            it 'sets an error on date_received field' do
              expect(refund.errors[:date_fee_paid]).to eq ["Enter the date", "Enter the date in this format DD/MM/YYYY"]
            end
          end
        end
      end
    end

  end

  describe '#save' do
    subject(:form) { described_class.new(detail) }

    subject(:update_form) do
      form.update(params)
      form.save
    end

    let(:detail) { create(:detail) }

    context 'when attributes are correct' do
      let(:params) {
        { refund: true, date_received: Time.zone.today,
          date_fee_paid: 4.months.ago.to_date,
          discretion_applied: true,
          discretion_manager_name: 'john',
          discretion_reason: 'test' }
      }

      it { is_expected.to be true }

      before do
        update_form
        detail.reload
      end

      it 'saves the parameters in the detail' do
        params.each do |key, value|
          expect(detail.send(key)).to eql(value)
        end
      end
    end
  end
end
