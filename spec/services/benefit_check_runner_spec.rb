require 'rails_helper'

RSpec.shared_examples 'runs benefit check record' do
  before do
    allow(BenefitCheckService).to receive(:new)
  end

  it 'creates a BenefitCheck record' do
    expect { run }.to change { application.benefit_checks.count }.by(1)
  end

  describe 'creates BenefitCheck record which' do
    let(:benefit_check) { application.benefit_checks.order(:id).last }

    before do
      run
    end

    it 'has the applicant\'s name' do
      expect(benefit_check.last_name).to eql(applicant.last_name)
    end

    it 'has the applicant\'s date of birth' do
      expect(benefit_check.date_of_birth).to eql(applicant.date_of_birth)
    end

    it 'has the applicant\'s ni_number' do
      expect(benefit_check.ni_number).to eql(applicant.ni_number)
    end

    describe 'has date_to_check set' do
      context 'when date_fee_paid is set on detail' do
        let(:detail) { create :detail, date_fee_paid: Time.zone.now - 1.month }

        it 'equals the date_fee_paid' do
          expect(benefit_check.date_to_check).to eql(detail.date_fee_paid)
        end
      end

      context 'when date_fee_paid is not set but date_received is set on detail' do
        let(:detail) { create :detail, date_received: Time.zone.now - 1.month }

        it 'equals the date_received' do
          expect(benefit_check.date_to_check).to eql(detail.date_received)
        end
      end
    end

    it 'has our_api_token set' do
      expect(benefit_check.our_api_token).not_to be_empty
    end

    it 'has parameter_hash set' do
      expect(benefit_check.parameter_hash).not_to be_empty
    end
  end

  describe 'with the created benefit check' do
    let(:benefit_check) { instance_double(BenefitCheck, outcome: 'full') }

    before do
      allow(BenefitCheck).to receive(:create).and_return(benefit_check)
      run
      application.reload
    end

    it 'sets type of application to benefit' do
      expect(application.application_type).to eql('benefit')
    end

    it 'sets the applicaiton outcome based on the result' do
      expect(application.outcome).to eql('full')
    end
  end
end

RSpec.describe BenefitCheckRunner do
  subject(:service) { described_class.new(application) }

  let(:existing_benefit_check) { nil }
  let(:applicant) { build(:applicant_with_all_details) }
  let(:detail) { build(:complete_detail) }
  let(:outcome) { nil }
  let(:application) { create(:application, applicant: applicant, detail: detail, income: nil, outcome: outcome) }

  describe '#can_run?' do
    subject { service.can_run? }

    context 'when all required details are present' do
      it { is_expected.to be true }
    end

    context 'when some details are missing' do
      let(:applicant) { build(:applicant) }

      it { is_expected.to be false }
    end
  end

  describe '#run' do
    before do
      existing_benefit_check
    end

    subject(:run) do
      service.run
    end

    context 'when all required fields are present on the application' do
      context 'when benefit check has not yet run' do
        include_examples 'runs benefit check record'
      end

      context 'when date_fee_paid is older then three months from today and date_received is blank' do
        let(:detail) { build(:complete_detail, :refund, date_fee_paid: Time.zone.today - 3.months, date_received: nil) }

        it 'does not create a BenefitCheck record' do
          expect { run }.not_to change { application.benefit_checks.count }
        end
      end

      context 'when benefit check has run before' do
        context 'when all the fields are exactly the same as before' do
          let(:existing_benefit_check) do
            create :benefit_check,
              :no_result,
              application: application,
              last_name: applicant.last_name,
              date_of_birth: applicant.date_of_birth,
              ni_number: applicant.ni_number,
              date_to_check: detail.date_received
          end

          it 'does not create a BenefitCheck record' do
            expect { run }.not_to change { application.benefit_checks.count }
          end
        end

        ['Yes', 'No', 'Undetermined', 'Deceased', 'BadRequest'].each do |result|
          context "when the DWP result is #{result}" do
            let(:existing_benefit_check) do
              create :benefit_check,
                application: application,
                last_name: applicant.last_name,
                date_of_birth: applicant.date_of_birth + 1.day,
                ni_number: applicant.ni_number,
                date_to_check: detail.date_received,
                dwp_result: result
            end

            it { expect { run }.not_to change { application.benefit_checks.count } }
          end
        end

        ['Unspecified Error', nil].each do |result|
          context "when the DWP result is #{result}" do
            before { allow(BenefitCheckService).to receive(:new) }

            let(:existing_benefit_check) do
              create :benefit_check,
                application: application,
                last_name: applicant.last_name,
                date_of_birth: applicant.date_of_birth + 1.day,
                ni_number: applicant.ni_number,
                date_to_check: detail.date_received,
                dwp_result: result
            end

            it { expect { run }.to change { application.benefit_checks.count } }
          end
        end

        context 'when there was an error before' do
          let(:existing_benefit_check) do
            create :benefit_check,
              :error_result,
              application: application,
              last_name: applicant.last_name,
              date_of_birth: applicant.date_of_birth,
              ni_number: applicant.ni_number,
              date_to_check: detail.date_received
          end

          include_examples 'runs benefit check record'
        end

        context 'when something has changed from before' do
          let(:existing_benefit_check) do
            create :benefit_check,
              application: application,
              last_name: 'Different',
              date_of_birth: applicant.date_of_birth,
              ni_number: applicant.ni_number,
              date_to_check: detail.date_received
          end

          include_examples 'runs benefit check record'
        end
      end
    end

    context 'when some fields are missing on the application' do
      let(:applicant) { build(:applicant) }

      it 'does not run benefit check' do
        expect { run }.not_to change { application.benefit_checks.count }
      end

      context 'when outcome already existed' do
        let(:outcome) { 'part' }

        it 'does not change the outcome' do
          run
          expect(application.reload.outcome).to eql('part')
        end
      end

      context 'when outcome was nil' do
        it 'sets outcome to none' do
          run
          expect(application.reload.outcome).to eql('none')
        end
      end
    end
  end

  describe '#can_override?' do

    subject { service.can_override? }

    context 'when the runner did not run' do
      before do
        allow(BenefitCheck).to receive(:create).and_return(benefit_check)
      end

      let(:benefit_check) { nil }

      it { is_expected.to be true }
    end

    context 'when the runner ran' do
      before do
        allow(service).to receive(:previous_check).and_return(benefit_check)
      end

      [
        { result: nil, overridable: true },
        { result: 'yes', overridable: false },
        { result: 'no', overridable: true },
        { result: 'deceased', overridable: false },
        { result: 'server unavailable', overridable: true },
        { result: 'superseded', overridable: false },
        { result: 'undetermined', overridable: true },
        { result: 'unspecified error', overridable: true }
      ].each do |definition|
        context "when result was #{definition[:result]}" do
          let(:benefit_check) { build_stubbed(:benefit_check, dwp_result: definition[:result]) }

          it { is_expected.to be definition[:overridable] }
        end
      end
    end
  end

  describe '#benefit_check_date_valid?' do

    subject { service.benefit_check_date_valid? }

    let(:detail) {
      build(:complete_detail,
        date_fee_paid: date_fee_paid,
        date_received: date_received)
    }

    context 'when date_fee_paid is older then three months' do
      let(:date_fee_paid) { Time.zone.today - 4.months }

      context 'and date_received is older then 3 months' do
        let(:date_received) { Time.zone.today - 3.months }
        it { is_expected.to be false }
      end

    end

    context 'when date_received is blank' do
      let(:date_received) { '' }

      context 'and date_fee_paid is older then 3 months' do
        let(:date_fee_paid) { Time.zone.today - 3.months }
        it { is_expected.to be false }
      end

      context 'and date_fee_paid is less then 3 months' do
        let(:date_fee_paid) { Time.zone.today - 2.months }
        it { is_expected.to be true }
      end
    end

    context 'when date_received and date_fee_paid is blank' do
      let(:date_fee_paid) { '' }
      let(:date_received) { '' }
      it { expect { service.benefit_check_date_valid? }.to raise_error(NoMethodError) }
    end
  end
end
