require 'rails_helper'

RSpec.describe RecordAppeal, type: :service do
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
    let(:updated_application) { service.call(correct: correct) && application.reload }
    let(:appeal) { updated_application.latest_appeal }

    context 'when correct evidence was provided' do
      let(:correct) { true }

      it 'records a correct appeal completed by the user' do
        expect(appeal).to have_attributes(correct: true, completed_by: user)
      end

      it 'moves the decision to full' do
        expect(updated_application.decision).to eq('full')
      end

      it 'clears the amount to pay' do
        expect(updated_application.amount_to_pay).to be_nil
      end

      it 'sets the decision cost to the fee' do
        expect(updated_application.decision_cost).to eq(application.detail.fee)
      end
    end

    context 'when correct evidence was not provided' do
      let(:correct) { false }

      before { create(:appeal, application: application, correct: false, created_at: 1.day.ago) }

      it 'records an incorrect appeal completed by the user' do
        expect(appeal).to have_attributes(correct: false, completed_by: user)
      end

      it 'keeps the earlier appeal' do
        expect(updated_application.appeals.count).to eq(2)
      end

      it 'does not change the application' do
        expect { service.call(correct: false) }.not_to(change { application.reload.attributes })
      end
    end

    context 'for a yes answer' do
      let(:correct) { true }

      before { create(:benefit_override, application: application, correct: false) }

      it 'keeps the original outcome' do
        expect(updated_application.outcome).to eq('none')
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

      it 'does not change the benefit override' do
        expect(updated_application.benefit_override).to have_attributes(correct: false)
      end
    end

    it 'returns true' do
      expect(service.call(correct: true)).to be true
    end

    context 'when the application cannot be updated' do
      before do
        allow(application).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'does not record the appeal' do
        expect { service.call(correct: true) }.to raise_error(ActiveRecord::RecordInvalid)
        expect(application.reload.appeals).to be_empty
      end
    end
  end
end
