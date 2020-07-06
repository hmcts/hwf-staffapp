require 'rails_helper'

RSpec.describe BenefitCheckRerunJob, type: :job do
  describe 'Re run benefit checks' do
    let(:application) { create :application, :benefit_type }
    let(:benefit_check) {
      create :benefit_check, application: application, dwp_result: dwp_result, error_message: 'LSCBC959: Service unavailable.'
    }

    context 'when DWP monitor status is' do
      let(:bc_runner) { instance_double(BenefitCheckRunner) }
      let(:benefit_checks) { class_double(BenefitCheck) }
      let(:bc_runner_job) { class_double(BenefitCheckRerunJob) }
      let(:time_to_run) { 15.minutes.from_now }

      before do
        allow(BenefitCheckRunner).to receive(:new).and_return bc_runner
        allow(bc_runner).to receive(:run)
        allow(BenefitCheckRerunJob).to receive(:delay).and_return bc_runner_job
        allow(bc_runner_job).to receive(:perform_later)
      end

      context 'loading latest benefit checks' do
        let(:dwp_result) { 'BadRequest' }
        before do
          create_list :benefit_check, 2, :yes_result
          create_list :benefit_check, 2, dwp_result: 'Unspecified error', error_message: 'Server broke connection'
          create_list :benefit_check, 2, dwp_result: 'BadRequest', error_message: 'LSCBC959: Service unavailable.'
          create_list :benefit_check, 2, dwp_result: 'Unspecified error', error_message: '500 Internal Server Error'
          Timecop.freeze(4.days.ago) do
            create_list :benefit_check, 2, dwp_result: 'Unspecified error', error_message: '500 Internal Server Error'
          end
        end

        it 'with BadRequest results' do
          BenefitCheckRerunJob.perform_now
          expect(bc_runner).to have_received(:run).exactly(6).times
        end

      end

      context 'offline' do
        let(:dwp_result) { 'BadRequest' }
        before { benefit_check }

        it 'for affected application' do
          BenefitCheckRerunJob.perform_now
          expect(bc_runner).to have_received(:run)
        end

        it 'load the application from benefit check' do
          BenefitCheckRerunJob.perform_now
          expect(BenefitCheckRunner).to have_received(:new).with(benefit_check.application)
        end
      end

      context 'online' do
        let(:dwp_result) { 'Yes' }
        before { benefit_check }

        it 'for affected application' do
          BenefitCheckRerunJob.perform_now
          expect(bc_runner).not_to have_received(:run)
        end

        it 'does not schedule another run' do
          Timecop.freeze(time_to_run - 15.minutes.ago) do
            BenefitCheckRerunJob.perform_now
            expect(bc_runner_job).not_to have_received(:perform_later)
          end
        end
      end

      context 'warning' do
        before { build_dwp_checks_with_bad_requests(3, 2) }

        it 'for affected application' do
          BenefitCheckRerunJob.perform_now
          expect(bc_runner).not_to have_received(:run)
        end

        it 'does not schedule another run' do
          Timecop.freeze(time_to_run - 15.minutes.ago) do
            BenefitCheckRerunJob.perform_now
            expect(bc_runner_job).not_to have_received(:perform_later)
          end
        end
      end
    end
  end
end
