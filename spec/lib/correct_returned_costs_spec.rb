require 'rails_helper'

RSpec.describe CorrectReturnedCosts do
  subject { described_class }

  let!(:application1) { create(:application_full_remission, :processed_state, decision_type: 'part', decision_cost: 30, outcome: 'none') }
  let!(:application2) { create(:application_full_remission, :processed_state, decision_type: 'evidence', decision_cost: 30, outcome: 'none') }
  let!(:application3) { create(:application_full_remission, :processed_state) }

  describe '#up!' do
    it 'works in sequence' do
      expect(subject.affected_records.size).to eql(2)
      subject.up!
      expect(subject.affected_records.size).to eql(0)
    end
  end
end
