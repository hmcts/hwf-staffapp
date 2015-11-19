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
    before { Timecop.freeze }
    after { Timecop.return }

    context 'when created with an evidence_check' do
      let(:object) { create(:evidence_check) }

      describe 'updates the objects.completed_by value' do
        before { resolver.resolve('return') }

        subject { object }

        it { expect(object.outcome).to eql 'return' }
        it { expect(object.completed_by.name).to eql user.name }
        it { expect(object.completed_at).to eql Time.zone.now }
        it { expect(object.application.decision).to eql 'none' }
        it { expect(object.application.decision_type).to eql 'evidence_check' }
      end
    end
  end
end
