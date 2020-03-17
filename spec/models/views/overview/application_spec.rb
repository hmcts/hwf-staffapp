require 'rails_helper'

RSpec.describe Views::Overview::Application do
  subject(:view) { described_class.new(application) }

  let(:application) { build_stubbed(:application) }

  describe '#all_fields' do
    subject { view.all_fields }

    it { is_expected.to eql(['benefits', 'dependants', 'number_of_children', 'total_monthly_income', 'savings']) }
  end

  describe '#income_result' do
    subject { view.income_result }

    let(:application) { build_stubbed(:application, outcome: outcome) }

    context 'when the application is a full remission' do
      let(:outcome) { 'full' }

      it { is_expected.to eq 'Yes' }
    end

    context 'when the application is a part remission' do
      let(:outcome) { 'part' }

      it { is_expected.to eq 'Yes' }
    end

    context 'when the application is a non remission' do
      let(:outcome) { 'none' }

      it { is_expected.to eq 'No' }
    end
  end

  describe '#savings_result' do
    subject { view.savings_result }

    before { allow(application.saving).to receive(:passed?).and_return(result) }

    context 'when the application has valid savings and investments' do
      let(:result) { true }

      it { is_expected.to eq 'Yes' }
    end

    context 'when the application does not have valid savings and investments' do
      let(:result) { false }

      it { is_expected.to eq 'No' }
    end
  end

  describe '#benefits_result' do
    subject { view.benefits_result }

    context 'for benefit type application' do
      let(:benefit_check) { build_stubbed(:benefit_check, application: application, dwp_result: result) }
      let(:application) { build_stubbed(:application, :benefit_type) }

      before do
        allow(application).to receive(:last_benefit_check).and_return(benefit_check)
      end

      context 'when the dwp_result is Yes' do
        let(:result) { 'Yes' }

        it { is_expected.to eq 'Yes' }
      end

      context 'when the dwp_result is No' do
        let(:result) { 'No' }

        it { is_expected.to eq 'No' }
      end

      context 'when a decision_overide exists' do
        let(:result) { 'no' }
        let!(:application) { create(:application, :benefit_type) }

        before { create :decision_override, application: application }

        it { is_expected.to eql "✓ Passed (by manager's decision)" }
      end
    end

    context 'for an income type application' do
      let(:application) { build_stubbed(:application, :income_type) }

      it { is_expected.to be nil }
    end
  end

  describe '#total_monthly_income' do
    subject { view.total_monthly_income }

    let(:application) { build_stubbed(:application, income: income) }

    context 'when income or thresholds are not set' do
      let(:income) { nil }

      it { is_expected.to be nil }
    end

    context 'when income is set' do
      let(:income) { 2082 }

      it 'returns currency formatted income' do
        is_expected.to eql('£2,082')
      end
    end

    context 'when thresholds are used' do
      let(:applicant) { build_stubbed(:applicant, married: true) }
      let(:application) do
        build_stubbed(:application, applicant: applicant,
                                    income: nil, children: 2,
                                    income_min_threshold_exceeded: min_exceeded, income_max_threshold_exceeded: max_exceeded)
      end

      context 'for income below thresholds' do
        let(:min_exceeded) { false }
        let(:max_exceeded) { nil }

        it 'returns correct below threshold text' do
          is_expected.to eql('Less than £1,735')
        end
      end

      context 'for income above thresholds' do
        let(:min_exceeded) { true }
        let(:max_exceeded) { true }

        it 'returns correct above threshold text' do
          is_expected.to eql('More than £5,735')
        end
      end
    end
  end

  describe '#total_monthly_income_from_evidence' do
    subject { view.total_monthly_income_from_evidence }

    let(:application) { build_stubbed(:application, evidence_check: evidence_check, income: 100) }

    context 'when evidence check is empty' do
      let(:evidence_check) { nil }

      it { is_expected.to be nil }
    end

    context 'when evidence check has nil income' do
      let(:evidence_check) { build_stubbed(:evidence_check, income: nil) }

      it { is_expected.to be nil }
    end

    context 'when evidence check is 123' do
      let(:evidence_check) { build_stubbed(:evidence_check, income: 123) }

      it { is_expected.to eql '£123' }
    end
  end

  describe '#number_of_children' do
    subject { view.number_of_children }

    let(:application) { build_stubbed(:application, children: children) }

    context 'when the number of children is set' do
      let(:children) { 5 }

      it { is_expected.to eql children }
    end

    context 'when the number of children is not set' do
      let(:children) { nil }

      it { is_expected.to be nil }
    end

  end

  describe '#return_type' do
    subject { view.return_type }

    let(:application) { build_stubbed :application, decision_type: decision_type, outcome: 'none' }

    context 'when the application has no decision_type' do
      let(:decision_type) { nil }

      it { is_expected.to be_nil }
    end

    context 'when the application was decided by application' do
      let(:decision_type) { 'application' }

      it { is_expected.to be_nil }
    end

    context 'when the application was decided by evidence check' do
      let(:decision_type) { 'evidence_check' }

      it { is_expected.to eql('evidence') }
    end

    context 'when the application was decided by part_payment' do
      let(:decision_type) { 'part_payment' }

      it { is_expected.to eql('payment') }
    end
  end

  describe '#result' do
    subject { view.result }

    let(:application) { build_stubbed(:application, outcome: outcome) }

    context 'when the application is a full remission' do
      let(:outcome) { 'full' }

      it { is_expected.to eq 'full' }
    end

    context 'when the application is a part remission' do
      let(:outcome) { 'part' }

      it { is_expected.to eq 'part' }
    end

    context 'when the application is a full remission' do
      let(:outcome) { 'none' }

      it { is_expected.to eq 'none' }
    end
  end

  describe '#amount_to_pay' do
    subject { view.amount_to_pay }

    shared_examples 'amount_to_pay examples' do
      context 'with decimal' do
        let(:amount) { 100.49 }

        it 'formats the fee amount correctly' do
          is_expected.to eq '£100.49'
        end
      end

      context 'without decimal' do
        let(:amount) { 100.00 }

        it 'formats the fee amount correctly' do
          is_expected.to eq '£100'
        end
      end

      context 'when its under £1' do
        let(:amount) { 0.49 }

        it 'formats the fee amount correctly' do
          is_expected.to eq '£0.49'
        end
      end

      context 'returns nil if amount_to_pay is nil' do
        let(:amount) { nil }

        it 'returns nil' do
          is_expected.to be nil
        end
      end
    end

    context 'when the application has evidence check' do
      let(:evidence) { build_stubbed :evidence_check, amount_to_pay: amount }
      let(:application) { build_stubbed :application, evidence_check: evidence, amount_to_pay: nil }

      include_examples 'amount_to_pay examples'
    end

    context 'when the application does not have evidence check' do
      let(:application) { build_stubbed :application, amount_to_pay: amount }

      include_examples 'amount_to_pay examples'
    end
  end
end
