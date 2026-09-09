require 'rails_helper'

RSpec.describe ReprocessBenefitApplication, type: :service do
  subject(:service) { described_class.new(application, user) }

  let(:user) { create(:staff) }
  let(:processed_by) { create(:staff) }
  let(:application) do
    create(:application, :benefit_type, :processed_state,
           outcome: 'none', amount_to_pay: 310, fee: '310.00',
           completed_by: processed_by, decision_cost: 0)
  end
  let(:now) { Time.zone.parse('2026-09-09 10:00:00') }

  before { travel_to(now) }

  it { is_expected.to be_a(described_class) }

  describe '#call' do
    let(:updated_application) { service.call && application.reload }
    let(:benefit_override) { updated_application.benefit_override }

    context 'when the application already has a failed benefit override' do
      let!(:existing_override) do
        create(:benefit_override, application: application, correct: false, completed_by: processed_by)
      end

      it 'keeps the same benefit override record' do
        expect(benefit_override).to eq(existing_override)
      end

      it 'marks the benefit override as correct' do
        expect(benefit_override.correct).to be true
      end

      it 'marks the benefit override as reprocessed' do
        expect(benefit_override.reprocessed).to be true
      end

      it 'records the user who reprocessed the application on the benefit override' do
        expect(benefit_override.completed_by).to eq(user)
      end
    end

    context 'when the application has no benefit override' do
      it 'creates a correct, reprocessed benefit override completed by the user' do
        expect(benefit_override).to have_attributes(correct: true, reprocessed: true, completed_by: user)
      end
    end

    describe 'the application decision' do
      it 'moves the decision to full' do
        expect(updated_application.decision).to eq('full')
      end

      it 'keeps the original outcome so the change is visible' do
        expect(updated_application.outcome).to eq('none')
      end

      it 'clears the amount to pay' do
        expect(updated_application.amount_to_pay).to be_nil
      end

      it 'sets the decision cost to the fee' do
        expect(updated_application.decision_cost).to eq(application.detail.fee)
      end

      it 'sets the decision date to now' do
        expect(updated_application.decision_date).to eq(now)
      end

      it 'keeps the application processed' do
        expect(updated_application).to be_processed
      end

      it 'keeps the original decision type' do
        expect(updated_application.decision_type).to eq('application')
      end

      it 'keeps the user who originally processed the application' do
        expect(updated_application.completed_by).to eq(processed_by)
      end
    end

    it 'returns true' do
      expect(service.call).to be true
    end

    context 'when the application cannot be updated' do
      before do
        allow(application).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'does not create the benefit override' do
        expect { service.call }.to raise_error(ActiveRecord::RecordInvalid)
        expect(application.reload.benefit_override).to be_nil
      end
    end
  end
end
