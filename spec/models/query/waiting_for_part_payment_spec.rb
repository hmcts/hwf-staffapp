require 'rails_helper'

RSpec.describe Query::WaitingForPartPayment, type: :model do
  describe '#find' do

    let(:user) { create :user }

    let(:application1) { create :application, :waiting_for_part_payment_state, office_id: user.office_id, completed_at: 1.day.ago }
    let(:application2) { create :application, :waiting_for_part_payment_state, office_id: user.office_id, completed_at: 5.days.ago }
    let(:application3) { create :application, :waiting_for_part_payment_state, office_id: user.office_id, completed_at: 2.days.ago }

    subject { described_class.new(user).find }

    it 'returns only applications which are in waiting_for_evidence state in order of completion' do
      is_expected.to eq([application2, application1])
    end
  end
end
