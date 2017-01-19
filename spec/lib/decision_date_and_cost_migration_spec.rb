require 'rails_helper'

RSpec.describe DecisionDateAndCostMigration do
  subject(:migration) { described_class.new }

  let!(:application1) do
    create(:application_full_remission, :processed_state, fee: 500, decision: 'full', decision_date: nil, decision_cost: nil)
  end

  let!(:application2) do
    create(:application_part_remission, :processed_state, decision_type: 'part_payment', fee: 500, amount_to_pay: 100, decision: 'part', decision_date: nil, decision_cost: nil) do |a|
      create(:part_payment_part_outcome, :completed, application: a)
    end
  end

  let!(:application3) do
    create(:application_part_remission, :processed_state, decision_type: 'part_payment', fee: 500, amount_to_pay: 100, decision: 'part', decision_date: nil, decision_cost: nil) do |a|
      create(:evidence_check_part_outcome, :completed, amount_to_pay: 150, application: a)
      create(:part_payment_part_outcome, :completed, application: a)
    end
  end

  let!(:application4) do
    create(:application_full_remission, :processed_state, decision_type: 'evidence_check', fee: 500, decision: 'full', decision_date: nil, decision_cost: nil) do |a|
      create(:evidence_check_full_outcome, :completed, application: a)
    end
  end

  let!(:application5) do
    create(:application_no_remission, :processed_state, fee: 500, decision: 'none', decision_date: nil, decision_cost: nil)
  end

  describe '#run!' do
    before do
      migration.run!
    end

    describe 'sets the correct decision_date and decision_cost' do
      describe 'application1' do
        # for processed application without evidence check or part payment
        subject(:application) { application1 }

        before { application.reload }

        it { expect(application.decision_date).to eql(application1.completed_at) }
        it { expect(application.decision_cost).to eq 500 }
      end

      describe 'application2' do
        # for processed application without evidence check but with part payment
        subject(:application) { application2 }

        before { application.reload }

        it { expect(application.decision_date).to eql(application2.part_payment.completed_at) }
        it { expect(application.decision_cost).to eq 400 }
      end

      describe 'application3' do
        # for processed application with evidence check but with part payment
        subject(:application) { application3 }

        before { application.reload }

        it { expect(application.decision_date).to eql(application3.part_payment.completed_at) }
        it { expect(application.decision_cost).to eq 350 }
      end

      describe 'application4' do
        # for processed application with evidence check but without part payment
        subject(:application) { application4 }

        before { application.reload }

        it { expect(application.decision_date).to eql(application4.evidence_check.completed_at) }
        it { expect(application.decision_cost).to eq 500 }
      end

      describe 'application5' do
        # for no remission application
        subject(:application) { application5 }

        before { application.reload }

        it { expect(application.decision_date).to eql(application5.completed_at) }
        it { expect(application.decision_cost).to eq 0 }
      end
    end
  end
end
