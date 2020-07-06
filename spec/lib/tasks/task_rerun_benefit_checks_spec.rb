require 'rake'

# rubocop:disable RSpec/DescribeClass
describe "#rerun_benefit_checks:perform_job" do
  let(:dwp_monitor) { instance_double('DwpMonitor') }

  before do
    Rake.application.rake_require('rerun_benefit_checks', [Rails.root.to_s + '/lib/tasks/'])
    described_class.define_task(:environment)
    allow(dwp_monitor).to receive(:state).and_return(dwp_state)
    allow(DwpMonitor).to receive(:new).and_return(dwp_monitor)
    allow(BenefitCheckRerunJob).to receive(:perform_now)
  end

  context 'DWPMonitor is online' do
    before { Rake.application.invoke_task "rerun_benefit_checks:perform_job" }
    let(:dwp_state) { 'online' }

    it 'will not rerun checks' do
      expect(BenefitCheckRerunJob).not_to have_received(:perform_now)
    end
  end

  context 'DWPMonitor is offline' do
    let(:dwp_state) { 'offline' }
    before { Rake.application.invoke_task "rerun_benefit_checks:perform_job" }

    it 'will rerun checks' do
      expect(BenefitCheckRerunJob).to have_received(:perform_now)
    end
  end

  context 'DWPMonitor is warning' do
    let(:dwp_state) { 'warning' }
    before { Rake.application.invoke_task "rerun_benefit_checks:perform_job" }

    it 'will rerun checks' do
      expect(BenefitCheckRerunJob).not_to have_received(:perform_now)
    end
  end
end
# rubocop:enable RSpec/DescribeClass
