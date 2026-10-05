require 'rails_helper'

RSpec.describe BenefitCheckers::ClaimsDecision do
  subject(:decision) { described_class.new(claims_response, window) }

  # Window the staff app sends for an application received on 2026-09-30
  let(:window) { instance_double(BenefitCheckers::EffectiveDates, effective_from: Date.new(2026, 8, 24), effective_to: Date.new(2026, 9, 30)) }
  let(:claims_response) { { 'data' => claims } }

  def claim(status:, start_date: nil, end_date: nil)
    attributes = { 'status' => status }
    attributes['startDate'] = start_date if start_date
    attributes['endDate'] = end_date if end_date
    { 'id' => 'claim', 'type' => 'Claim', 'attributes' => attributes }
  end

  # Some claims carry no status of their own, only one per award
  def claim_with_awards(award_statuses:, start_date: nil, status: nil)
    attributes = { 'awards' => award_statuses.map { |award_status| { 'status' => award_status, 'amount' => 8500 } } }
    attributes['status'] = status if status
    attributes['startDate'] = start_date if start_date
    { 'id' => 'claim', 'type' => 'Claim', 'attributes' => attributes }
  end

  describe '#on_benefits?' do
    context 'with a claim in payment that started before the window' do
      let(:claims) { [claim(status: 'in_payment', start_date: '2025-08-15')] }

      it { expect(decision.on_benefits?).to be true }
    end

    context 'with a claim in payment that started inside the window' do
      let(:claims) { [claim(status: 'in_payment', start_date: '2026-09-14')] }

      it { expect(decision.on_benefits?).to be true }
    end

    context 'with a claim in payment that started on the last day of the window' do
      let(:claims) { [claim(status: 'in_payment', start_date: '2026-09-30')] }

      it { expect(decision.on_benefits?).to be true }
    end

    context 'with a claim in payment that started after the window' do
      let(:claims) { [claim(status: 'in_payment', start_date: '2026-10-15')] }

      it { expect(decision.on_benefits?).to be false }
    end

    context 'with a claim that ended before the window' do
      let(:claims) { [claim(status: 'active', start_date: '2025-05-15', end_date: '2026-08-21')] }

      it { expect(decision.on_benefits?).to be false }
    end

    context 'with a claim that ended on the first day of the window' do
      let(:claims) { [claim(status: 'active', start_date: '2025-05-15', end_date: '2026-08-24')] }

      it { expect(decision.on_benefits?).to be true }
    end

    context 'with a closed claim inside the window' do
      let(:claims) { [claim(status: 'claim_closed', start_date: '2025-08-15', end_date: '2026-09-14')] }

      it 'is not on benefits because the status is not an on-benefits one' do
        expect(decision.on_benefits?).to be false
      end
    end

    context 'with a closed claim followed by a claim in payment' do
      let(:claims) do
        [
          claim(status: 'claim_closed', start_date: '2025-05-15', end_date: '2026-09-18'),
          claim(status: 'in_payment', start_date: '2026-09-19')
        ]
      end

      it 'looks past the first claim' do
        expect(decision.on_benefits?).to be true
      end
    end

    context 'with a claim in payment that has no dates' do
      let(:claims) { [claim(status: 'ongoing_award')] }

      it { expect(decision.on_benefits?).to be true }
    end

    context 'with an unparseable date' do
      let(:claims) { [claim(status: 'in_payment', start_date: 'not-a-date')] }

      it 'ignores the date and decides on the status' do
        expect(decision.on_benefits?).to be true
      end
    end

    context 'when the application has no date to build a window from' do
      let(:window) { instance_double(BenefitCheckers::EffectiveDates, effective_from: nil, effective_to: nil) }
      let(:claims) { [claim(status: 'in_payment', start_date: '2030-01-15')] }

      it 'decides on the status alone' do
        expect(decision.on_benefits?).to be true
      end
    end

    context 'with a claim that has no status of its own but a live award' do
      let(:claims) { [claim_with_awards(award_statuses: ['live'], start_date: '2021-01-01')] }

      it { expect(decision.on_benefits?).to be true }
    end

    context 'with a claim that has no status of its own and no live award' do
      let(:claims) { [claim_with_awards(award_statuses: ['ended'], start_date: '2021-01-01')] }

      it { expect(decision.on_benefits?).to be false }
    end

    context 'with a claim that has a live award among others' do
      let(:claims) { [claim_with_awards(award_statuses: ['ended', 'live'], start_date: '2021-01-01')] }

      it { expect(decision.on_benefits?).to be true }
    end

    context 'with a live award on a claim that started after the window' do
      let(:claims) { [claim_with_awards(award_statuses: ['live'], start_date: '2026-10-15')] }

      it { expect(decision.on_benefits?).to be false }
    end

    context 'with a live award on a claim whose own status is closed' do
      let(:claims) { [claim_with_awards(award_statuses: ['live'], start_date: '2021-01-01', status: 'claim_closed')] }

      it 'goes by the status of the claim' do
        expect(decision.on_benefits?).to be false
      end
    end

    context 'with a claim that has no status and no awards' do
      let(:claims) { [{ 'id' => 'claim', 'type' => 'Claim', 'attributes' => { 'startDate' => '2021-01-01' } }] }

      it { expect(decision.on_benefits?).to be false }
    end

    context 'with no claims' do
      let(:claims) { [] }

      it { expect(decision.on_benefits?).to be false }
    end

    context 'with a nil response' do
      let(:claims_response) { nil }

      it { expect(decision.on_benefits?).to be false }
    end
  end
end
