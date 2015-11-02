require 'rails_helper'

RSpec.describe Query::ProcessedApplications, type: :model do
  describe '.find' do
    subject { described_class.new.find }

    let!(:application1) { create :application }
    let!(:application2) { create :application }
    let!(:application3) { create :application }
    let!(:application4) { create :application }
    let!(:application5) { create :application }
    let!(:application6) { create :application }

    before do
      create :evidence_check, application: application1
      create :evidence_check, :completed, application: application2

      create :payment, application: application3
      create :payment, :completed, application: application4

      create :evidence_check, :completed, application: application5
      create :payment, :completed, application: application5
    end

    it 'contains applications completely processed' do
      is_expected.to match_array([application2, application4, application5, application6])
    end
  end
end
