require 'rails_helper'

RSpec.describe DecisionCostMigration do
  subject(:migration) { described_class }

  let!(:failed_application) { create :application_no_remission, :processed_state, decision: 'full', decision_cost: 0, decision_type: 'override', application_type: 'none', decision_date: Time.zone.now }

  before do
    create :decision_override, application: failed_application
    create_list :application_full_remission, 7, :processed_state, decision_date: Time.zone.now
  end

  it 'setup creates many records' do
    expect(Application.count).to eq 8
  end

  describe '#run!' do
    before do
      migration.run!
      failed_application.reload
    end

    it 'updates the correct decision_cost' do
      expect(failed_application.decision_cost).to eq failed_application.detail.fee
    end

    it 'leaves no records to be updated' do
      expect(migration.affected_records.count).to eql 0
    end
  end

  describe '.affected_records' do
    subject { migration.affected_records.count }

    it { is_expected.to eql 1 }
  end
end
