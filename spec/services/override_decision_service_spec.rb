require 'rails_helper'

RSpec.describe OverrideDecisionService, type: :service do

  let(:application) { create :application, :processed_state, outcome: 'full' }
  let(:decision_override) { DecisionOverride.new(application: application) }
  let(:form) { Forms::Application::DecisionOverride.new(decision_override) }

  before do
    form.update_attributes(
      created_by_id: user.id,
      value: 'other',
      reason: 'foo reason bar'
    )
  end

  let(:reason) { 'foo reason bar' }
  let(:user) { create :staff }

  subject(:service) { described_class.new(application, form) }

  it { is_expected.to be_a(described_class) }

  describe '#set!' do
    before { service.set! }

    context 'updates the application' do
      subject { application }

      it { expect(subject.decision).to eql 'full' }
      it { expect(subject.decision_type).to eql('override') }
      it { expect(subject.decision_cost).to eql(application.detail.fee) }

      it 'adds a decision_override to the application' do
        expect(application.decision_override.present?).to be true
      end

      it 'saves the application' do
        expect(subject.changed?).to be false
        expect(subject.decision_override.changed?).to be false
      end
    end
  end
end
