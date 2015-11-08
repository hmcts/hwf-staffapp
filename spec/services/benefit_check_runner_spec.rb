require 'rails_helper'

RSpec.shared_examples 'runs benefit check record' do
  before do
    allow(BenefitCheckService).to receive(:new)
  end

  it 'creates a BenefitCheck record' do
    expect { subject }.to change { application.benefit_checks.count }.by(1)
  end

  describe 'creates BenefitCheck record which' do
    let(:benefit_check) { application.last_benefit_check }

    before do
      subject
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
        let(:detail) { create :detail, date_fee_paid: '10/10/2015' }

        it 'equals the date_fee_paid' do
          expect(benefit_check.date_to_check).to eql(detail.date_fee_paid)
        end
      end

      context 'when date_fee_paid is not set but date_received is set on detail' do
        let(:detail) { create :detail, date_received: '10/10/2015' }

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
    let(:benefit_check) { double(BenefitCheck, outcome: 'full') }

    before do
      allow(BenefitCheck).to receive(:create).and_return(benefit_check)
      subject
      application.reload
    end

    it 'sets type of application to benefit' do
      expect(application.application_type).to eql('benefit')
    end

    it 'sets the applicaiton outcome based on the result' do
      expect(application.application_outcome).to eql('full')
    end
  end
end

RSpec.describe BenefitCheckRunner do
  let(:existing_benefit_check) { nil }
  let(:applicant) { build(:applicant_with_all_details) }
  let(:detail) { build(:complete_detail) }
  let(:application) { create(:application, applicant: applicant, detail: detail, income: nil) }

  subject(:service) { described_class.new(application) }

  describe '#run' do
    before do
      existing_benefit_check
    end

    subject do
      service.run
    end

    context 'when all required fields are present on the application' do
      context 'when benefit check has not yet run' do
        include_examples 'runs benefit check record'
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
            expect { subject }.not_to change { application.benefit_checks.count }
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
        expect { subject }.not_to change { application.benefit_checks.count }
      end
    end
  end
end
