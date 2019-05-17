require 'rails_helper'

RSpec.describe DecisionOverride, type: :model do
  subject(:override) { build_stubbed :decision_override }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:application) }
    it { is_expected.to validate_presence_of(:user) }

    describe 'reason' do
      subject(:override) { build_stubbed :decision_override, reason: reason }

      context 'when nil' do
        let(:reason) { nil }

        it { is_expected.not_to be_valid }
      end

      context 'when set' do
        let(:reason) { 'a reason' }

        it { is_expected.to be_valid }
      end
    end
  end
end
