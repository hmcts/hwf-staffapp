require 'rails_helper'

RSpec.describe Query::WaitingForPayment, type: :model do
  describe '#find' do

    let(:user) { create :user }
    let!(:application1) { create :application, user_id: user.id, office_id: user.office_id }
    let!(:application2) { create :application, user_id: user.id, office_id: user.office_id }
    let!(:application3) { create :application, user_id: user.id, office_id: user.office_id }
    let!(:payment1) { create :payment, application: application1, expires_at: 2.days.from_now }
    let!(:payment2) { create :payment, application: application2, expires_at: 1.days.from_now }
    let!(:payment3) { create :payment, application: application3, expires_at: 1.days.from_now, completed_at: 2.days.ago }

    subject { described_class.new(user).find }

    it 'returns only applications which have uncompleted Payment reference in order of expiry' do
      is_expected.to eq([application2, application1])
    end
  end
end
