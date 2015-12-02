require 'rails_helper'

RSpec.describe Query::ProcessedApplications, type: :model do
  let(:office) { create(:office) }
  let(:user) { create :user, office: office }

  subject(:query) { described_class.new(user) }

  describe '#find' do
    subject { query.find }

    let!(:application1) { create :application_full_remission, office: office }
    let!(:application2) { create :application_full_remission, office: office }
    let!(:application3) { create :application_full_remission, office: office }
    let!(:other_office_application) { create :application_full_remission }
    let!(:application4) { create :application_full_remission, office: office }
    let!(:application6) { create :application_full_remission, office: office }
    let!(:application5) { create :application_full_remission, office: office }
    let!(:application7) { create :application, office: office, outcome: nil }
    let!(:application8) { create :application_full_remission, :uncompleted, office: office }

    before do
      create :evidence_check, application: application1
      create :evidence_check, :completed, application: application2

      create :part_payment, application: application3
      create :part_payment, :completed, application: application4

      create :evidence_check, :completed, application: application5
      create :part_payment, :completed, application: application5
    end

    it "contains applications completely processed from user's office in order of creation" do
      is_expected.to eq([application2, application4, application6, application5])
    end
  end
end
