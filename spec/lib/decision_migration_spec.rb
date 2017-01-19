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

    describe 'application with a completed evidence check takes its outcome as decision' do
      subject(:application) { application1 }

      before { application.reload }

      it { expect(application.decision).to eq 'part' }
      it { expect(application.decision_type).to eq 'evidence_check' }
    end

    describe 'application with a completed evidence check as return marks decision as none' do
      subject(:application) { application2 }

      before { application.reload }

      it { expect(application.decision).to eq 'none' }
      it { expect(application.decision_type).to eql 'evidence_check' }
    end

    describe 'application with a uncompleted evidence check does not set decision' do
      subject(:application) { application3 }

      before { application.reload }

      it { expect(application.decision).to be nil }
      it { expect(application.decision_type).to be nil }
    end

    describe 'application with a completed part payment takes its outcome as decision' do
      subject(:application) { application4 }

      before { application.reload }

      it { expect(application.decision).to eq 'part' }
      it { expect(application.decision_type).to eq 'part_payment' }
    end

    describe 'application with a completed part payment as return marks decision as none' do
      subject(:application) { application5 }

      before { application.reload }

      it { expect(application.decision).to eq 'none' }
      it { expect(application.decision_type).to eq 'part_payment' }
    end

    describe 'application with a uncompleted part payment does not set decision' do
      subject(:application) { application6 }

      before { application.reload }

      it { expect(application.decision).to be nil }
      it { expect(application.decision_type).to be nil }
    end

    describe 'completed application' do
      subject(:application) { application7 }

      before { application.reload }

      it { expect(application.decision).to eq 'full' }
      it { expect(application.decision_type).to eq 'application' }
    end
  end
end
