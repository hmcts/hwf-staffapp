require 'rake'

# rubocop:disable RSpec/DescribeClass
describe "#rerun_benefit_checks:perform_job" do
  let(:dwp_monitor) { instance_double('DwpMonitor') }

  before do
    allow(dwp_monitor).to receive(:state).and_return(dwp_state)
    allow(DwpMonitor).to receive(:new).and_return(dwp_monitor)
    allow(Rails.logger).to receive(:info)
    allow(Rails.logger).to receive(:error)
    Rake::Task.define_task(:environment)
  end

  context 'no errors' do
    before {
      allow(BenefitCheckRerunJob).to receive(:perform_now)
      Rake.application.rake_require('rerun_benefit_checks', [File.join(Rails.root.to_s, '/lib/tasks/')])
      Rake::Task["rerun_benefit_checks:perform_job"].invoke
      Rake::Task["rerun_benefit_checks:perform_job"].reenable
    }
    context 'DWPMonitor is online' do
      let(:dwp_state) { 'online' }

      it 'will not rerun checks' do
        expect(BenefitCheckRerunJob).not_to have_received(:perform_now)
      end
      it { expect(Rails.logger).to have_received(:info).with("Rake task rerun_benefit_checks - no rerun needed") }
    end

    context 'DWPMonitor is offline' do
      let(:dwp_state) { 'offline' }

      it 'will rerun checks' do
        expect(BenefitCheckRerunJob).to have_received(:perform_now)
      end
      it { expect(Rails.logger).to have_received(:info).with("Rake task rerun_benefit_checks - rerun was triggered") }
    end

    context 'DWPMonitor is warning' do
      let(:dwp_state) { 'warning' }

      it 'will rerun checks' do
        expect(BenefitCheckRerunJob).not_to have_received(:perform_now)
      end
      it { expect(Rails.logger).to have_received(:info).with("Rake task rerun_benefit_checks - no rerun needed") }
    end
  end

  context 'Raise an exception' do
    let(:dwp_state) { 'offline' }
    let(:exception) { StandardError.new('test') }

    before do
      allow(BenefitCheckRerunJob).to receive(:perform_now).and_raise(exception)
      Rake.application.rake_require('rerun_benefit_checks', [File.join(Rails.root.to_s, '/lib/tasks/')])
      Rake::Task["rerun_benefit_checks:perform_job"].invoke
      Rake::Task["rerun_benefit_checks:perform_job"].reenable
    end

    it { expect(Rails.logger).to have_received(:error).with("Rake task rerun_benefit_checks - failed: test") }
  end
end
# rubocop:enable RSpec/DescribeClass
