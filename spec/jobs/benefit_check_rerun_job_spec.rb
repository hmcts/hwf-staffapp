require 'rails_helper'

RSpec.describe BenefitCheckRerunJob do
  describe 'Re run benefit checks' do
    let(:application) { create(:application, :benefit_type) }
    let(:online_application) { create(:online_application_with_all_details, :benefits) }
    let(:benefit_check) {
      create(:benefit_check, applicationable: application, dwp_result: dwp_result, error_message: dwp_message)
    }
    let(:dwp_message) { 'LSCBC959: Service unavailable.' }

    context 'when DWP monitor status is' do
      let(:bc_runner) { instance_double(BenefitCheckRunner) }
      let(:online_bc_runner) { instance_double(OnlineBenefitCheckRunner) }
      let(:benefit_checks) { class_double(BenefitCheck) }
      let(:bc_runner_job) { class_double(described_class) }
      let(:time_to_run) { 15.minutes.from_now }

      before do
        allow(BenefitCheckRunner).to receive(:new).and_return bc_runner
        allow(OnlineBenefitCheckRunner).to receive(:new).and_return online_bc_runner
        allow(bc_runner).to receive(:run)
        allow(online_bc_runner).to receive(:run)
        allow(described_class).to receive(:delay).and_return bc_runner_job
        allow(bc_runner_job).to receive(:perform_later)
      end

      context 'loading latest benefit checks' do
        let(:dwp_result) { 'BadRequest' }
        before do
          create_list(:benefit_check, 2, :yes_result)
          create(:benefit_check, dwp_result: 'Server unavailable', error_message: 'The benefits checker is not available at the moment. Please check again later.')
          create(:benefit_check, dwp_result: 'Unspecified error', error_message: 'Server broke connection')
          create_list(:benefit_check, 1, dwp_result: 'BadRequest', error_message: 'LSCBC959: Service unavailable.')
          create_list(:benefit_check, 1, dwp_result: 'BadRequest', error_message: 'LSCBC958: Service unavailable.')
          create_list(:benefit_check, 1, dwp_result: 'Unspecified error', error_message: '500 Internal Server Error')
          create_list(:benefit_check, 2, applicationable: application, dwp_result: 'Unspecified error', error_message: '500 Internal Server Error')
          create_list(:benefit_check, 2, applicationable: online_application, dwp_result: 'Unspecified error', error_message: '500 Internal Server Error')
          travel_to(4.days.ago) do
            create_list(:benefit_check, 2, dwp_result: 'Unspecified error', error_message: '500 Internal Server Error')
          end
        end

        it 'BC runner runs' do
          described_class.perform_now
          expect(bc_runner).to have_received(:run).exactly(6).times
        end

        it 'Online BC runner runs' do
          described_class.perform_now
          expect(online_bc_runner).to have_received(:run).exactly(1).times
        end

      end

      context 'offline' do
        let(:dwp_result) { 'BadRequest' }
        before { benefit_check }

        it 'for affected application' do
          described_class.perform_now
          expect(bc_runner).to have_received(:run)
        end

        it 'load the application from benefit check' do
          described_class.perform_now
          expect(BenefitCheckRunner).to have_received(:new).with(benefit_check.applicationable)
        end
      end

      context 'online' do
        let(:dwp_result) { 'Yes' }
        let(:dwp_message) { '' }
        before { benefit_check }

        it 'for affected application' do
          described_class.perform_now
          expect(bc_runner).not_to have_received(:run)
        end

        it 'does not schedule another run' do
          travel_to(time_to_run - 15.minutes) do
            described_class.perform_now
            expect(bc_runner_job).not_to have_received(:perform_later)
          end
        end
      end

      context 'warning' do
        before { build_dwp_checks_with_bad_requests(3, 2) }

        it 'for affected application' do
          described_class.perform_now
          expect(bc_runner).not_to have_received(:run)
        end

        it 'does not schedule another run' do
          travel_to(time_to_run - 15.minutes) do
            described_class.perform_now
            expect(bc_runner_job).not_to have_received(:perform_later)
          end
        end
      end
    end
  end
end
