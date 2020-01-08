require 'rails_helper'

RSpec.describe CCMCCEvidenceCheckRules do
  let(:ccmcc) { create :office, name: 'ccmcc', entity_code: 'DH403' }
  let(:digital) { create :office, name: 'digital', entity_code: 'dig' }
  let(:application) { create :application, office: ccmcc, fee: 5000 }
  let(:ccmcc_check_rules) { described_class.new(application) }

  describe 'CCMCC rule_applies?' do
    it { expect(ccmcc_check_rules.rule_applies?).to be true }

    context 'not ccmcc application' do
      let(:application) { create :application, office: digital, fee: 5000 }
      it { expect(ccmcc_check_rules.rule_applies?).to be false }
    end

    context 'refund application' do
      let(:application) { create :application, :refund, office: ccmcc, fee: 5000 }
      it { expect(ccmcc_check_rules.rule_applies?).to be false }
    end
  end

  context 'ccmcc application' do
    describe '5k rule' do
      it { expect(ccmcc_check_rules.rule_applies?).to be true }

      it 'has the frequency of 1 - as every application applies' do
        ccmcc_check_rules.rule_applies?
        expect(ccmcc_check_rules.frequency).to be 1
      end
    end

    describe 'under 5k rule' do
      let(:application) { create :application, office: ccmcc, fee: 4999 }
      it { expect(ccmcc_check_rules.rule_applies?).to be false }
    end
  end
end
