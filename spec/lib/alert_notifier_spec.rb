require 'rails_helper'

RSpec.describe AlertNotifier do

  describe '#run!' do
    describe 'check dwp status' do
      before do
        dwp_monitor = instance_double('DwpMonitor', state: state)
        allow(DwpMonitor).to receive(:new).and_return dwp_monitor
      end

      context 'online' do
        let(:state) { 'online' }

        it "do not send and email if all is good" do
          expect(ApplicationMailer).not_to receive(:dwp_is_down_notifier)
          AlertNotifier.run!
        end
      end

      context 'offline' do
        let(:state) { 'offline' }

        it "send and email if dwp is offline" do
          mailer = instance_double('ActionMailer::MessageDelivery')
          allow(ApplicationMailer).to receive(:dwp_is_down_notifier).and_return mailer
          expect(mailer).to receive(:deliver_now)
          AlertNotifier.run!
        end
      end
    end
  end
end
