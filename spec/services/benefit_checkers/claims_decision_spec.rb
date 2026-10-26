require 'rails_helper'

RSpec.describe BenefitCheckers::ClaimsDecision do
  subject(:decision) { described_class.new(claims_response, window) }

  # Window the staff app sends for an application received on 2026-09-30
  let(:window) { instance_double(BenefitCheckers::EffectiveDates, effective_from: Date.new(2026, 8, 24), effective_to: Date.new(2026, 9, 30)) }
  let(:claims_response) { { 'data' => claims } }

  # An Income Support claim with a live award that pays, so only the claim's own status and dates vary
  def claim(status:, start_date: nil, end_date: nil)
    attributes = { 'benefitType' => 'income_support', 'status' => status, 'awards' => [paying_award] }
    attributes['startDate'] = start_date if start_date
    attributes['endDate'] = end_date if end_date
    { 'id' => 'claim', 'type' => 'Claim', 'attributes' => attributes }
  end

  # Some claims carry no status of their own, only one per award
  def claim_with_awards(award_statuses:, start_date: nil, status: nil)
    attributes = { 'benefitType' => 'employment_support_allowance_income_based',
                   'awards' => award_statuses.map { |award_status| paying_award.merge('status' => award_status) } }
    attributes['status'] = status if status
    attributes['startDate'] = start_date if start_date
    { 'id' => 'claim', 'type' => 'Claim', 'attributes' => attributes }
  end

  def paying_award
    { 'startDate' => '2020-01-01', 'status' => 'live', 'amount' => 8_500 }
  end

  # Any benefit other than Universal Credit: one award, usually with no end date
  def other_claim(benefit_type:, amount: 8_500, status: 'active', award: {})
    attributes = { 'benefitType' => benefit_type, 'status' => status, 'startDate' => '2025-01-01',
                   'awards' => [paying_award.merge('amount' => amount).merge(award)] }
    { 'id' => 'claim', 'type' => 'Claim', 'attributes' => attributes }
  end

  # A Universal Credit claim has one award per assessment period. Amounts are in pence.
  def uc_claim(awards:, status: 'in_payment', start_date: '2025-01-01')
    attributes = { 'benefitType' => 'universal_credit', 'status' => status, 'startDate' => start_date, 'awards' => awards }
    { 'id' => 'claim', 'type' => 'Claim', 'attributes' => attributes }
  end

  def uc_award(start_date:, end_date:, amount: 74_500, take_home_pay: 0, status: 'live')
    award = { 'startDate' => start_date, 'endDate' => end_date, 'status' => status, 'amount' => amount }
    award['assessmentAttributes'] = { 'takeHomePay' => take_home_pay } unless take_home_pay.nil?
    award
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
      let(:claims) do
        [{ 'id' => 'claim', 'type' => 'Claim', 'attributes' => { 'benefitType' => 'income_support', 'startDate' => '2021-01-01' } }]
      end

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

  # RST-8365: a Universal Credit claim also needs a live award inside the window
  # with take home pay under £500 and an amount over £0. See CHANGELOG.md
  describe '#on_benefits? for Universal Credit' do
    # The window is 2026-08-24 to 2026-09-30
    let(:award_in_window) { { start_date: '2026-08-28', end_date: '2026-09-27' } }
    let(:award_before_window) { { start_date: '2026-07-01', end_date: '2026-07-31' } }

    context 'with an active claim, take home pay under £500 and an amount over £0' do
      let(:claims) { [uc_claim(awards: [uc_award(**award_in_window, amount: 74_500, take_home_pay: 41_050)])] }

      it { expect(decision.on_benefits?).to be true }
    end

    context 'with take home pay of exactly £500' do
      let(:claims) { [uc_claim(awards: [uc_award(**award_in_window, take_home_pay: 50_000)])] }

      it { expect(decision.on_benefits?).to be false }
    end

    context 'with take home pay one penny under £500' do
      let(:claims) { [uc_claim(awards: [uc_award(**award_in_window, take_home_pay: 49_999)])] }

      it { expect(decision.on_benefits?).to be true }
    end

    context 'with an amount of £0' do
      let(:claims) { [uc_claim(awards: [uc_award(**award_in_window, amount: 0)])] }

      it { expect(decision.on_benefits?).to be false }
    end

    context 'with no amount on the award' do
      let(:claims) { [uc_claim(awards: [uc_award(**award_in_window, amount: nil)])] }

      it { expect(decision.on_benefits?).to be false }
    end

    context 'with no take home pay on the award' do
      let(:claims) { [uc_claim(awards: [uc_award(**award_in_window, take_home_pay: nil)])] }

      it 'treats it as £0' do
        expect(decision.on_benefits?).to be true
      end
    end

    context 'with a claim that is not active' do
      let(:claims) { [uc_claim(status: 'claim_closed', awards: [uc_award(**award_in_window)])] }

      it { expect(decision.on_benefits?).to be false }
    end

    context 'with two awards in the window and only one that passes' do
      let(:claims) do
        [uc_claim(awards: [uc_award(start_date: '2026-07-28', end_date: '2026-08-27', amount: 0, take_home_pay: 90_000),
                           uc_award(**award_in_window)])]
      end

      it { expect(decision.on_benefits?).to be true }
    end

    context 'when the only passing award ended before the window' do
      let(:claims) { [uc_claim(awards: [uc_award(**award_before_window), uc_award(**award_in_window, take_home_pay: 90_000)])] }

      it { expect(decision.on_benefits?).to be false }
    end

    context 'when the only passing award starts after the window' do
      let(:claims) { [uc_claim(awards: [uc_award(start_date: '2026-10-01', end_date: '2026-10-31')])] }

      it { expect(decision.on_benefits?).to be false }
    end

    context 'when no award falls inside the window' do
      let(:claims) { [uc_claim(awards: [uc_award(**award_before_window)])] }

      it { expect(decision.on_benefits?).to be false }
    end

    context 'when the claim has no awards' do
      let(:claims) { [uc_claim(awards: [])] }

      it { expect(decision.on_benefits?).to be false }
    end

    context 'when the passing award in the window is superseded' do
      let(:claims) do
        [uc_claim(awards: [uc_award(**award_in_window, status: 'superseded'),
                           uc_award(**award_in_window, amount: 0, take_home_pay: 90_000)])]
      end

      it 'only looks at live awards' do
        expect(decision.on_benefits?).to be false
      end
    end

    context 'with an award that has no end date' do
      let(:claims) { [uc_claim(awards: [uc_award(start_date: '2026-01-01', end_date: nil)])] }

      it { expect(decision.on_benefits?).to be true }
    end

    context 'when the application has no date to build a window from' do
      let(:window) { instance_double(BenefitCheckers::EffectiveDates, effective_from: nil, effective_to: nil) }
      let(:claims) { [uc_claim(awards: [uc_award(**award_before_window)])] }

      it 'looks at every live award' do
        expect(decision.on_benefits?).to be true
      end
    end
  end

  # RST-8365: the other listed benefits need a live award inside the window that pays over £0
  describe '#on_benefits? for the other listed benefits' do
    ['pensions_credit', 'income_support', 'employment_support_allowance_income_based',
     'job_seekers_allowance_income_based'].each do |benefit_type|
      context "with an active #{benefit_type} claim that pays" do
        let(:claims) { [other_claim(benefit_type: benefit_type)] }

        it { expect(decision.on_benefits?).to be true }
      end

      context "with an active #{benefit_type} claim that pays £0" do
        let(:claims) { [other_claim(benefit_type: benefit_type, amount: 0)] }

        it { expect(decision.on_benefits?).to be false }
      end
    end

    context 'with a claim that is not active' do
      let(:claims) { [other_claim(benefit_type: 'income_support', status: 'claim_closed')] }

      it { expect(decision.on_benefits?).to be false }
    end

    context 'with a suspended claim' do
      let(:claims) { [other_claim(benefit_type: 'job_seekers_allowance_income_based', status: 'suspended')] }

      it { expect(decision.on_benefits?).to be false }
    end

    context 'when the only award ended before the window' do
      let(:claims) { [other_claim(benefit_type: 'income_support', award: { 'endDate' => '2026-08-21' })] }

      it { expect(decision.on_benefits?).to be false }
    end

    context 'when the only award starts after the window' do
      let(:claims) { [other_claim(benefit_type: 'income_support', award: { 'startDate' => '2026-10-15' })] }

      it { expect(decision.on_benefits?).to be false }
    end

    context 'when the award is not live' do
      let(:claims) { [other_claim(benefit_type: 'pensions_credit', award: { 'status' => 'cacs_decision_hist' })] }

      it { expect(decision.on_benefits?).to be false }
    end

    context 'when the award has no amount' do
      let(:claims) { [other_claim(benefit_type: 'income_support', amount: nil)] }

      it { expect(decision.on_benefits?).to be false }
    end

    context 'with take home pay of £500 or more on the award' do
      let(:claims) do
        [other_claim(benefit_type: 'income_support', award: { 'assessmentAttributes' => { 'takeHomePay' => 90_000 } })]
      end

      it 'does not apply the Universal Credit take home pay limit' do
        expect(decision.on_benefits?).to be true
      end
    end
  end

  # RST-8365: one passing claim is enough, whichever listed benefit it is
  describe '#on_benefits? with Universal Credit and another listed benefit' do
    let(:passing_uc) { uc_claim(awards: [uc_award(start_date: '2026-08-28', end_date: '2026-09-27')]) }
    let(:failing_uc) { uc_claim(awards: [uc_award(start_date: '2026-08-28', end_date: '2026-09-27', take_home_pay: 90_000)]) }
    let(:passing_other) { other_claim(benefit_type: 'income_support') }
    let(:failing_other) { other_claim(benefit_type: 'income_support', amount: 0) }

    context 'when Universal Credit passes and the other benefit fails' do
      let(:claims) { [passing_uc, failing_other] }

      it { expect(decision.on_benefits?).to be true }
    end

    context 'when Universal Credit fails and the other benefit passes' do
      let(:claims) { [failing_uc, passing_other] }

      it { expect(decision.on_benefits?).to be true }
    end

    context 'when both pass' do
      let(:claims) { [passing_uc, passing_other] }

      it { expect(decision.on_benefits?).to be true }
    end

    context 'when both fail' do
      let(:claims) { [failing_uc, failing_other] }

      it { expect(decision.on_benefits?).to be false }
    end
  end

  # The one reason that decided the check, named after the RST-8365 scenario wording
  describe '#reason' do
    let(:in_window) { { start_date: '2026-08-28', end_date: '2026-09-27' } }

    def reason_for(*claims_list)
      described_class.new({ 'data' => claims_list }, window).reason
    end

    it 'says when no claims came back' do
      expect(reason_for).to eq 'no_claims_returned'
      expect(described_class.new(nil, window).reason).to eq 'no_claims_returned'
    end

    it 'says when the benefit is not listed' do
      expect(reason_for(other_claim(benefit_type: 'carers_allowance'))).to eq 'benefit_type_not_listed'
    end

    it 'says when the claim is not active inside the window' do
      expect(reason_for(other_claim(benefit_type: 'income_support', status: 'claim_closed'))).to eq 'claim_not_active_within_range'
      expect(reason_for(claim(status: 'in_payment', start_date: '2026-10-15'))).to eq 'claim_not_active_within_range'
    end

    it 'says when payments are suspended' do
      expect(reason_for(uc_claim(status: 'suspended', awards: [uc_award(**in_window)]))).to eq 'payments_suspended_within_range'
    end

    it 'says when take home pay is over the limit' do
      expect(reason_for(uc_claim(awards: [uc_award(**in_window, take_home_pay: 50_000)]))).to eq 'take_home_pay_over_limit'
    end

    it 'says when nothing was paid inside the window' do
      expect(reason_for(uc_claim(awards: [uc_award(**in_window, amount: 0)]))).to eq '0_paid_within_range'
      expect(reason_for(uc_claim(awards: [uc_award(start_date: '2026-07-01', end_date: '2026-07-31')]))).to eq '0_paid_within_range'
      expect(reason_for(other_claim(benefit_type: 'income_support', amount: 0))).to eq '0_paid_within_range'
    end

    it 'prefers the take home pay reason when an award was paid but earned too much' do
      awards = [uc_award(**in_window, amount: 0), uc_award(**in_window, take_home_pay: 90_000)]
      expect(reason_for(uc_claim(awards: awards))).to eq 'take_home_pay_over_limit'
    end

    it 'says which kind of benefit passed' do
      expect(reason_for(uc_claim(awards: [uc_award(**in_window)]))).to eq 'universal_credit_passed'
      expect(reason_for(other_claim(benefit_type: 'job_seekers_allowance_income_based'))).to eq 'other_benefit_passed'
    end

    context 'with several claims' do
      let(:closed) { other_claim(benefit_type: 'income_support', status: 'claim_closed') }
      let(:unpaid) { other_claim(benefit_type: 'job_seekers_allowance_income_based', amount: 0) }
      let(:passing) { uc_claim(awards: [uc_award(**in_window)]) }

      it 'gives the passing reason whichever claim passed' do
        expect(reason_for(closed, passing)).to eq 'universal_credit_passed'
        expect(reason_for(passing, closed)).to eq 'universal_credit_passed'
      end

      it 'gives the first claim its reason when none passed' do
        expect(reason_for(closed, unpaid)).to eq 'claim_not_active_within_range'
        expect(reason_for(unpaid, closed)).to eq '0_paid_within_range'
      end
    end

    it 'agrees with on_benefits?' do
      decision = described_class.new({ 'data' => [other_claim(benefit_type: 'income_support', amount: 0)] }, window)
      expect(decision.on_benefits?).to be false
      expect(decision.reason).to eq '0_paid_within_range'
    end
  end

  # RST-7882: what the raw data export shows about the claim the decision used
  describe '#summary' do
    let(:in_window) { { start_date: '2026-08-28', end_date: '2026-09-27' } }

    def summary_for(*claims_list)
      described_class.new({ 'data' => claims_list }, window).summary
    end

    it 'describes a passing Universal Credit claim and the award it paid from' do
      claim = uc_claim(awards: [uc_award(**in_window, take_home_pay: 41_050)])

      expect(summary_for(claim)).to eq(benefit_types: 'universal_credit', claim_status: 'active', take_home_pay: 41_050)
    end

    it 'describes a passing claim for another benefit, which has no take home pay' do
      expect(summary_for(other_claim(benefit_type: 'income_support'))).to eq(
        benefit_types: 'income_support', claim_status: 'active', take_home_pay: nil
      )
    end

    it 'lists every benefit type DWP returned, in response order' do
      claims = [other_claim(benefit_type: 'income_support', status: 'claim_closed'), uc_claim(awards: [uc_award(**in_window)])]

      expect(summary_for(*claims)[:benefit_types]).to eq 'income_support and universal_credit'
    end

    it 'takes the status and pay from the claim that decided: the passing one' do
      claims = [other_claim(benefit_type: 'income_support', status: 'claim_closed'), uc_claim(awards: [uc_award(**in_window)])]

      expect(summary_for(*claims)).to include(claim_status: 'active', take_home_pay: 0)
    end

    it 'takes them from the first claim when none passed' do
      claims = [uc_claim(status: 'suspended', awards: [uc_award(**in_window)]), other_claim(benefit_type: 'income_support', amount: 0)]

      expect(summary_for(*claims)).to include(claim_status: 'suspended', take_home_pay: nil)
    end

    it 'says not active for a closed claim' do
      expect(summary_for(other_claim(benefit_type: 'income_support', status: 'claim_closed'))[:claim_status]).to eq 'not active'
    end

    it 'says not active for an active claim outside the window' do
      expect(summary_for(claim(status: 'in_payment', start_date: '2026-10-15'))[:claim_status]).to eq 'not active'
    end

    it 'says suspended for a suspended claim' do
      expect(summary_for(uc_claim(status: 'suspended', awards: [uc_award(**in_window)]))).to include(claim_status: 'suspended', take_home_pay: nil)
    end

    it 'keeps the take home pay of an active Universal Credit claim that failed on it' do
      claim = uc_claim(awards: [uc_award(**in_window, take_home_pay: 90_000)])

      expect(summary_for(claim)).to include(claim_status: 'active', take_home_pay: 90_000)
    end

    it 'keeps the take home pay of an active Universal Credit claim that paid nothing' do
      claim = uc_claim(awards: [uc_award(**in_window, amount: 0, take_home_pay: 41_050)])

      expect(summary_for(claim)).to include(claim_status: 'active', take_home_pay: 41_050)
    end

    it 'has no take home pay when no award falls inside the window' do
      claim = uc_claim(awards: [uc_award(start_date: '2026-07-01', end_date: '2026-07-31', take_home_pay: 41_050)])

      expect(summary_for(claim)).to include(claim_status: 'active', take_home_pay: nil)
    end

    it 'is empty when DWP returned no claims' do
      expect(summary_for).to eq(benefit_types: nil, claim_status: nil, take_home_pay: nil)
      expect(described_class.new(nil, window).summary).to eq(benefit_types: nil, claim_status: nil, take_home_pay: nil)
    end
  end

  # RST-8365: only the listed benefits count
  describe '#on_benefits? with no listed benefit' do
    context 'with an active benefit that is not on the list' do
      let(:claims) { [other_claim(benefit_type: 'carers_allowance', amount: 33_320)] }

      it { expect(decision.on_benefits?).to be false }
    end

    context 'with a claim that has no benefit type' do
      let(:claims) { [{ 'id' => 'claim', 'type' => 'Claim', 'attributes' => { 'status' => 'active', 'awards' => [paying_award] } }] }

      it { expect(decision.on_benefits?).to be false }
    end

    context 'with a claim that has empty attributes' do
      let(:claims) { [{ 'id' => 'income_support_0', 'type' => 'Claim', 'attributes' => {} }] }

      it { expect(decision.on_benefits?).to be false }
    end

    context 'with an unlisted benefit and a listed one that passes' do
      let(:claims) { [other_claim(benefit_type: 'carers_allowance'), other_claim(benefit_type: 'pensions_credit')] }

      it { expect(decision.on_benefits?).to be true }
    end
  end
end
