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

    it 'has user\'s id' do
      expect(benefit_check.user_id).to eql(user.id)
    end

    describe 'has date_to_check set' do
      context 'when date_fee_paid is set on detail' do
        let(:detail) { create(:detail, date_fee_paid: 1.month.ago) }

        it 'equals the date_fee_paid' do
          expect(benefit_check.date_to_check).to eql(detail.date_fee_paid)
        end
      end

      context 'when date_fee_paid is not set but date_received is set on detail' do
        let(:detail) { create(:detail, date_received: 1.month.ago) }

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

  describe 'application updates' do
    let(:benefit_check) { instance_double(BenefitCheck, outcome: 'full') }
    let(:application) { create(:application, applicant: applicant, detail: detail, income: nil, outcome: outcome, amount_to_pay: 1000) }

    before do
      allow(BenefitCheck).to receive(:create).and_return(benefit_check)
      run
      application.reload
    end

    it 'sets type of application to benefit' do
      expect(application.application_type).to eql('benefit')
      expect(application.amount_to_pay).to be_nil
    end

    context 'Outcome none' do
      let(:benefit_check) { instance_double(BenefitCheck, outcome: 'none') }

      it 'sets type of application to benefit' do
        expect(application.application_type).to eql('benefit')
        expect(application.amount_to_pay).to eq(1000)
      end
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
  let(:user) { application.user }
  let(:app_insight) { instance_double(ApplicationInsights::TelemetryClient, flush: '') }

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
      allow(ApplicationInsights::TelemetryClient).to receive(:new).and_return app_insight
      allow(app_insight).to receive(:track_event)
      existing_benefit_check
    end

    subject(:run) do
      service.run
    end

    context 'when all required fields are present on the application' do
      context 'when benefit check has not yet run' do
        it_behaves_like 'runs benefit check record'
      end

      context 'when date_fee_paid is older then three months from today and date_received is blank' do
        let(:detail) { build(:complete_detail, :refund, date_fee_paid: Time.zone.today - 3.months, date_received: nil) }

        it 'does run a BenefitCheckService call' do
          allow(BenefitCheckService).to receive(:new)
          run
          expect(BenefitCheckService).to have_received(:new)
          expect(app_insight).to have_received(:track_event)
        end
      end

      context 'when benefit check has run before' do
        context 'when all the fields are exactly the same as before' do
          let(:existing_benefit_check) do
            create(:benefit_check,
                   :no_result,
                   applicationable: application,
                   last_name: applicant.last_name,
                   date_of_birth: applicant.date_of_birth,
                   ni_number: applicant.ni_number,
                   date_to_check: detail.date_received)
          end

          it 'does not create a BenefitCheck record' do
            expect { run }.not_to change { application.benefit_checks.count }
          end
        end

        context 'when there was an error before' do
          let(:existing_benefit_check) do
            create(:benefit_check,
                   :error_result,
                   applicationable: application,
                   last_name: applicant.last_name,
                   date_of_birth: applicant.date_of_birth,
                   ni_number: applicant.ni_number,
                   date_to_check: detail.date_received)
          end

          it_behaves_like 'runs benefit check record'
        end

        context 'when something has changed from before' do
          let(:existing_benefit_check) do
            create(:benefit_check,
                   applicationable: application,
                   last_name: 'Different',
                   date_of_birth: applicant.date_of_birth,
                   ni_number: applicant.ni_number,
                   date_to_check: detail.date_received)
          end

          it_behaves_like 'runs benefit check record'
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

    context 'when there is a benefit_check' do
      let(:existing_benefit_check) do
        create(:benefit_check,
               :yes_result,
               applicationable: application,
               last_name: applicant.last_name,
               date_of_birth: applicant.date_of_birth,
               ni_number: applicant.ni_number,
               date_to_check: detail.date_received)
      end

      it 'sets outcome to last banefit check' do
        run
        expect(application.reload.outcome).to eql('full')
      end
    end

  end

  describe '#can_override?' do
    before do
      allow(BenefitCheck).to receive(:create).and_return(benefit_check)
    end

    subject { service.can_override? }

    context 'when the runner did not run' do
      let(:benefit_check) { nil }

      it { is_expected.to be true }
    end

    context 'when the runner ran' do
      [
        { result: nil, overridable: true },
        { result: 'yes', overridable: false },
        { result: 'no', overridable: true },
        { result: 'deceased', overridable: false },
        { result: 'server unavailable', overridable: true },
        { result: 'superseded', overridable: false },
        { result: 'undetermined', overridable: true },
        { result: 'unspecified error', overridable: true },
        { result: 'Unspecified error', overridable: true }
      ].each do |definition|
        context "when result was #{definition[:result]}" do
          let(:benefit_check) { build_stubbed(:benefit_check, dwp_result: definition[:result]) }

          it { is_expected.to be definition[:overridable] }
        end
      end
    end
  end

  describe '#checks_allowed?' do
    before do
      allow(DwpWarning).to receive(:order).and_return([dwp_warning, 'test'])
      allow(BenefitCheckService).to receive(:new)
    end

    context 'when DwpWarning is offline' do
      let(:dwp_warning) { instance_double(DwpWarning, check_state: 'offline') }
      it 'do not allow calls' do
        service.run
        expect(BenefitCheckService).not_to have_received(:new)
      end
    end

    context 'when DwpWarning is online' do
      let(:dwp_warning) { instance_double(DwpWarning, check_state: 'online') }
      it 'allow calls' do
        service.run
        expect(BenefitCheckService).to have_received(:new)
      end
    end
  end
end
