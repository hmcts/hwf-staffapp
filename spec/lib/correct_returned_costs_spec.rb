require 'rails_helper'

RSpec.describe CorrectReturnedCosts do
  subject(:service) { described_class }

  before do
    create(:application_full_remission, :processed_state, decision_type: 'part', decision_cost: 30, outcome: 'none')
    create(:application_full_remission, :processed_state, decision_type: 'evidence', decision_cost: 30, outcome: 'none')
    create(:application_full_remission, :processed_state)
  end

  describe '#up!' do
    describe 'before it is run' do
      it { expect(service.affected_records.size).to eq 2 }
    end
    describe 'after it runs' do
      before { service.up! }

      it { expect(service.affected_records.size).to eq 0 }
    end
  end
end
