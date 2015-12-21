require 'rails_helper'

RSpec.describe FinanceReportBuilder do

  let(:user) { create :user }
  let(:business_entity) { create :business_entity }
  let!(:application1) do
    create(:application_full_remission, :processed_state, fee: 500, decision: 'full', decision_date: Time.zone.today, business_entity: business_entity)
  end

  let(:start_date) { Time.zone.today.-1.month }
  let(:end_date) { Time.zone.today.+1.month }
  subject(:frb) { described_class.new(start_date, end_date) }

  describe '#to_csv' do
    subject { frb.to_csv }

    it { is_expected.to be_a String }
  end
end
