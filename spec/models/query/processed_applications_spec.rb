require 'rails_helper'

RSpec.describe Query::ProcessedApplications, type: :model do
  let(:office) { create(:office) }
  let(:user) { create :user, office: office }

  subject(:query) { described_class.new(user) }

  describe '#find' do
    subject { query.find }

    let!(:application1) { create :application, office: office }
    let!(:application2) { create :application, office: office }
    let!(:application3) { create :application, office: office }
    let!(:other_office_application) { create :application }
    let!(:application4) { create :application, office: office }
    let!(:application6) { create :application, office: office }
    let!(:application5) { create :application, office: office }

    before do
      create :evidence_check, application: application1
      create :evidence_check, :completed, application: application2

      create :payment, application: application3
      create :payment, :completed, application: application4

      create :evidence_check, :completed, application: application5
      create :payment, :completed, application: application5
    end

    it 'contains applications completely processed from user\'s office in order of creation' do
      is_expected.to eq([application2, application4, application6, application5])
    end
  end
end
