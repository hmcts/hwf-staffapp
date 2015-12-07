require 'rails_helper'

RSpec.describe Query::DeletedApplications, type: :model do
  let(:office) { create(:office) }
  let(:user) { create :user, office: office }

  subject(:query) { described_class.new(user) }

  describe '#find' do
    subject { query.find }

    let!(:application1) { create :application_full_remission, office: office }
    let!(:application2) { create :application_full_remission, :deleted_state, office: office }
    let!(:other_office_application) { create :application_full_remission, :processed_state }
    let!(:application3) { create :application_full_remission, :deleted_state, office: office }

    it "contains applications completely deleted from user's office in order of creation" do
      is_expected.to eq([application2, application3])
    end
  end
end
