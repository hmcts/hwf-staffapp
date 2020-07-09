require 'rake'

# rubocop:disable RSpec/DescribeClass
describe "#rerun_benefit_checks:perform_job" do
  let(:dwp_monitor) { instance_double('DwpMonitor') }

  before do
    allow(dwp_monitor).to receive(:state).and_return(dwp_state)
    allow(DwpMonitor).to receive(:new).and_return(dwp_monitor)
    allow(BenefitCheckRerunJob).to receive(:perform_now)
    Rake::Task.define_task(:environment)
    Rake.application.rake_require('rerun_benefit_checks', [Rails.root.to_s + '/lib/tasks/'])
    Rake::Task["rerun_benefit_checks:perform_job"].invoke
    Rake::Task["rerun_benefit_checks:perform_job"].reenable
  end

  context 'DWPMonitor is online' do
    let(:dwp_state) { 'online' }

    it 'will not rerun checks' do
      expect(BenefitCheckRerunJob).not_to have_received(:perform_now)
    end
  end

  context 'DWPMonitor is offline' do
    let(:dwp_state) { 'offline' }

    it 'will rerun checks' do
      expect(BenefitCheckRerunJob).to have_received(:perform_now)
    end
  end

  context 'DWPMonitor is warning' do
    let(:dwp_state) { 'warning' }

    it 'will rerun checks' do
      expect(BenefitCheckRerunJob).not_to have_received(:perform_now)
    end
  end
end
# rubocop:enable RSpec/DescribeClass
