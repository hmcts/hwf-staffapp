require 'rails_helper'

RSpec.describe LowIncomeEvidenceCheckRules do
  subject(:low_income_rule) { described_class.new(application) }
  let(:application) { create(:application, income: income, office: office) }
  let(:income) { 100 }
  let(:office) { create(:office, entity_code: 'dig') }
  describe '#rule_applies?' do
    subject(:rule_applies?) { low_income_rule.rule_applies? }

    describe 'income range' do
      context 'under 101' do
        let(:income) { 100 }
        it { is_expected.to be true }
      end
      context 'eq 101' do
        let(:income) { 101 }
        it { is_expected.to be true }
      end
      context '0 income' do
        let(:income) { 0 }
        it { is_expected.to be true }
      end
      context 'nil income' do
        let(:income) { nil }
        it { is_expected.to be true }
      end
    end

    describe 'office check' do
      context 'exluded NB243' do
        let(:office) { create(:office, entity_code: 'NB243') }
        it { is_expected.to be false }
      end
      context 'exluded TI122' do
        let(:office) { create(:office, entity_code: 'TI122') }
        it { is_expected.to be false }
      end
      context 'not excluded' do
        let(:office) { create(:office, entity_code: 'dig') }
        it { is_expected.to be true }
      end
    end

    context 'pre ucd' do
      before { application.detail.update(calculation_scheme: FeatureSwitching::CALCULATION_SCHEMAS[1]) }
      let(:office) { create(:office, entity_code: 'dig') }
      it { is_expected.to be true }
    end

    context 'post ucd' do
      before { application.detail.update(calculation_scheme: FeatureSwitching::CALCULATION_SCHEMAS[0]) }
      let(:office) { create(:office, entity_code: 'dig') }
      it { is_expected.to be false }
    end
  end

  describe '#annotation' do
    it { expect(low_income_rule.annotation).to eq "1 under 101" }
  end
end
