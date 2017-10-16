require 'rails_helper'

RSpec.describe HomeHelper do

  describe '#path_for_application_based_on_state' do
    let(:evidence_check) { create(:evidence_check, application: last_application) }
    let(:part_payment) { create(:part_payment, application: last_application) }

    context 'waiting_for_evidence' do
      let(:last_application) { create(:application, :waiting_for_evidence_state) }
      before { evidence_check }

      it { expect(path_for_application_based_on_state(last_application)).to eql("/evidence/#{evidence_check.id}") }
    end

    context 'waiting_for_part_payment' do
      let(:last_application) { create(:application, :waiting_for_part_payment_state) }
      before { part_payment }

      it { expect(path_for_application_based_on_state(last_application)).to eql("/part_payments/#{part_payment.id}") }
    end
  end
end
