require 'rails_helper'

RSpec.describe OverrideDecisionService, type: :service do
  subject(:service) { described_class.new(application, form) }

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

  it { is_expected.to be_a(described_class) }

  describe '#set!' do
    before { service.set! }

    context 'updates the application' do
      subject(:updated_application) { application }

      it { expect(updated_application.decision).to eql 'full' }
      it { expect(updated_application.decision_type).to eql('override') }
      it { expect(updated_application.decision_cost).to eql(application.detail.fee) }

      it 'adds a decision_override to the application' do
        expect(updated_application.decision_override.present?).to be true
      end

      describe 'saves the application' do
        it { expect(updated_application.changed?).to be false }
        it { expect(updated_application.decision_override.changed?).to be false }
      end
    end
  end
end
