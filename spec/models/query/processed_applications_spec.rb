require 'rails_helper'

RSpec.describe Query::ProcessedApplications, type: :model do
  subject(:query) { described_class.new(user) }

  let(:office) { create(:office) }
  let(:user) { create :user, office: office }
  let(:jurisdiction) { create(:jurisdiction) }

  describe '#find' do
    subject { query.find }

    let(:application1) { create :application_full_remission, office: office, jurisdiction: user.jurisdiction }
    let!(:application2) { create :application_full_remission, :processed_state, office: office, decision_date: Time.zone.parse('2016-03-01'), jurisdiction: jurisdiction }
    let(:other_office_application) { create :application_full_remission, :processed_state }
    let!(:application3) { create :application_full_remission, :processed_state, office: office, decision_date: Time.zone.parse('2016-05-01'), jurisdiction: user.jurisdiction }

    it "contains applications completely processed from user's office in descending order of processed date" do
      is_expected.to eq([application3, application2])
    end

    context 'jurisdiction' do
      subject { query.find(jurisdiction_id: jurisdiction.id) }
      it { is_expected.to eq([application2]) }
    end
  end
end
