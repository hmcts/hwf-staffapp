require 'rails_helper'

RSpec.describe DecisionMigration do

  subject(:migration) { described_class.new }

  let!(:application1) do
    create(:application_full_remission, state: :processed, decision: nil, decision_type: nil).tap do |a|
      create(:evidence_check_part_outcome, :completed, application: a)
    end
  end

  let!(:application2) do
    create(:application_full_remission, state: :processed, decision: nil, decision_type: nil).tap do |a|
      create(:evidence_check_part_outcome, :completed, outcome: 'return', application: a)
    end
  end

  let!(:application3) do
    create(:application_full_remission, state: :waiting_for_evidence, decision: nil, decision_type: nil).tap do |a|
      create(:evidence_check_part_outcome, application: a)
    end
  end

  let!(:application4) do
    create(:application_part_remission, state: :processed, decision: nil, decision_type: nil).tap do |a|
      create(:part_payment_part_outcome, :completed, application: a)
    end
  end

  let!(:application5) do
    create(:application_part_remission, state: :processed, decision: nil, decision_type: nil).tap do |a|
      create(:part_payment_part_outcome, :completed, outcome: 'return', application: a)
    end
  end

  let!(:application6) do
    create(:application_part_remission, state: :waiting_for_part_payment, decision: nil, decision_type: nil).tap do |a|
      create(:part_payment_part_outcome, application: a)
    end
  end

  let!(:application7) do
    create(:application_full_remission, state: :processed, decision: nil, decision_type: nil)
  end

  describe '#run!' do
    before do
      migration.run!
    end

    it 'sets decision and decision_type for processed applications when missing' do
      # application with a completed evidence check takes its outcome as decision
      application1.reload
      expect(application1.decision).to eql('part')
      expect(application1.decision_type).to eql('evidence_check')

      # application with a completed evidence check as return marks decision as none
      application2.reload
      expect(application2.decision).to eql('none')
      expect(application2.decision_type).to eql('evidence_check')

      # application with a uncompleted evidence check does not set decision
      application3.reload
      expect(application3.decision).to be nil
      expect(application3.decision_type).to be nil

      # application with a completed part payment takes its outcome as decision
      application4.reload
      expect(application4.decision).to eql('part')
      expect(application4.decision_type).to eql('part_payment')

      # application with a completed part payment as return marks decision as none
      application5.reload
      expect(application5.decision).to eql('none')
      expect(application5.decision_type).to eql('part_payment')

      # application with a uncompleted part payment does not set decision
      application6.reload
      expect(application6.decision).to be nil
      expect(application6.decision_type).to be nil

      # completed application
      application7.reload
      expect(application7.decision).to eql('full')
      expect(application7.decision_type).to eql('application')
    end
  end
end
