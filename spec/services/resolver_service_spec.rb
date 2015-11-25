require 'rails_helper'

describe ResolverService do
  let(:user) { build_stubbed(:user) }

  subject(:resolver) { described_class.new(object, user) }

  describe '#process' do
    Timecop.freeze(Time.zone.now) do
      before { resolver.process }

      context 'when created with an application' do
        let(:object) { create(:application_full_remission) }

        describe 'updates the objects.completed_by value' do
          subject { object.completed_by.name }

          it { is_expected.to eql user.name }
        end

        describe 'sets the completed_at value' do
          subject { object.completed_at }

          it { is_expected.not_to be_nil }
        end
      end

      context 'when created with a part-payment' do
        let(:object) { create(:part_payment) }

        describe 'updates the objects.completed_by value' do
          subject { object.completed_by.name }

          it { is_expected.to eql user.name }
        end

        describe 'sets the completed_at value' do
          subject { object.completed_at }

          it { is_expected.not_to be_nil }
        end
      end

      context 'when created with an evidence_check' do
        let(:object) { create(:evidence_check_full_outcome) }

        describe 'updates the objects.completed_by value' do
          subject { object.completed_by.name }

          it { is_expected.to eql user.name }
        end

        describe 'sets the completed_at value' do
          subject { object.completed_at }

          it { is_expected.not_to be_nil }
        end
      end

    end
  end

  describe '#resolve' do
    before do
      Timecop.freeze
      resolver.resolve(outcome)
    end

    after { Timecop.return }

    subject { object }

    context 'when created with an evidence_check' do
      let(:object) { create(:evidence_check) }

      describe "when outcome is 'return'" do
        let(:outcome) { 'return' }

        it { expect(subject.outcome).to eql 'return' }
        it { expect(subject.application.decision).to eql 'none' }

        it_behaves_like 'resolver service for user, timestamps and decision_type', 'evidence_check'
      end

      describe "when outcome is 'full'" do
        let(:outcome) { 'full' }

        it { expect(subject.outcome).to eql 'full' }
        it { expect(subject.application.decision).to eql 'full' }

        it_behaves_like 'resolver service for user, timestamps and decision_type', 'evidence_check'
      end

      describe "when outcome is 'part'" do
        let(:outcome) { 'part' }

        it { expect(subject.outcome).to eql 'part' }
        it { expect(subject.application.decision).to eql 'part' }

        it_behaves_like 'resolver service for user, timestamps and decision_type', 'evidence_check'
      end

      describe "when outcome is 'none'" do
        let(:outcome) { 'none' }

        it { expect(subject.outcome).to eql 'none' }
        it { expect(subject.application.decision).to eql 'none' }

        it_behaves_like 'resolver service for user, timestamps and decision_type', 'evidence_check'
      end
    end

    context 'when created with a part-payment' do
      context 'check different outcomes' do
        let(:object) { create(:part_payment) }

        describe "when outcome is 'return'" do
          let(:outcome) { 'return' }

          it { expect(subject.outcome).to eql 'return' }
          it { expect(subject.application.decision).to eql 'none' }

          it_behaves_like 'resolver service for user, timestamps and decision_type', 'part_payment'
        end

        describe "when outcome is 'none'" do
          let(:outcome) { 'none' }

          it { expect(subject.outcome).to eql 'none' }
          it { expect(subject.application.decision).to eql 'none' }

          it_behaves_like 'resolver service for user, timestamps and decision_type', 'part_payment'
        end

        describe "when outcome is 'part'" do
          let(:outcome) { 'part' }

          it { expect(subject.outcome).to eql 'part' }
          it { expect(subject.application.decision).to eql 'part' }

          it_behaves_like 'resolver service for user, timestamps and decision_type', 'part_payment'
        end
      end
    end
  end
end
