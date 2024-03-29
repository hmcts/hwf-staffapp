require 'rails_helper'

RSpec.describe Query::DeletedApplications do
  subject(:query) { described_class.new(user) }

  let(:office) { create(:office) }
  let(:user) { create(:user, office: office) }
  let(:jurisdiction) { create(:jurisdiction) }

  describe '#find' do
    subject { query.find }

    let(:application1) { create(:application_full_remission, office: office, jurisdiction: user.jurisdiction) }
    let!(:application2) { create(:application_full_remission, :deleted_state, office: office, deleted_at: Time.zone.parse('2015-10-19'), jurisdiction: jurisdiction) }
    let(:other_office_application) { create(:application_full_remission, :processed_state) }
    let!(:application3) { create(:application_full_remission, :deleted_state, office: office, deleted_at: Time.zone.parse('2016-02-29'), jurisdiction: user.jurisdiction) }

    it "contains applications completely deleted from user's office in descending order of deletion" do
      is_expected.to eq([application3, application2])
    end

    context 'jurisdiction' do
      subject { query.find(jurisdiction_id: jurisdiction.id) }
      it { is_expected.to eq([application2]) }

      context 'empty jurisdiction value' do
        subject { query.find(jurisdiction_id: '') }
        it { is_expected.to eq([application3, application2]) }
      end

      context 'nil filter' do
        subject { query.find(nil) }
        it { is_expected.to eq([application3, application2]) }
      end
    end

  end
end
