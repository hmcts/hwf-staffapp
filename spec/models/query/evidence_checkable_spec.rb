require 'rails_helper'

RSpec.describe Query::EvidenceCheckable, type: :model do
  describe '.find_all' do
    subject { described_class.new.find_all }

    let!(:application_1) { create :application_part_remission }
    let!(:application_2) { create :application_full_remission }
    let(:application_3) { create :application_no_remission }
    let!(:emergency_application) { create :application_full_remission, emergency_reason: 'REASON' }

    it 'includes only part and full remission applications' do
      is_expected.to match_array([application_1, application_2])
    end

    it 'does not include emergency applications' do
      is_expected.not_to include emergency_application
    end
  end
end
