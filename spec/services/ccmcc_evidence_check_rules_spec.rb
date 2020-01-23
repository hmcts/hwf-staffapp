require 'rails_helper'

RSpec.describe CCMCCEvidenceCheckRules do
  let(:ccmcc) { create :office, name: 'ccmcc', entity_code: 'DH403' }
  let(:digital) { create :office, name: 'digital', entity_code: 'dig' }
  let(:application) { create :application, office: ccmcc, fee: 5000, amount_to_pay: 0 }
  let(:ccmcc_check_rules) { described_class.new(application) }

  describe 'CCMCC rule_applies?' do
    it { expect(ccmcc_check_rules.rule_applies?).to be true }

    context 'not ccmcc application' do
      before { ccmcc }
      let(:application) { create :application, office: digital, fee: 5000, amount_to_pay: 0 }
      it { expect(ccmcc_check_rules.rule_applies?).to be false }
    end

    context 'refund application' do
      let(:application) { create :application, :refund, office: ccmcc, fee: 5000, amount_to_pay: 0 }
      it { expect(ccmcc_check_rules.rule_applies?).to be true }
    end
  end

  describe 'ccmcc office id' do
    it { expect(ccmcc_check_rules.office_id).to eql(ccmcc.id) }
  end

  describe 'CCMCC clean_annotation_data' do
    before do
      ccmcc_check_rules.rule_applies?
      ccmcc_check_rules.clean_annotation_data
    end

    it { expect(ccmcc_check_rules.check_type).to be nil }
  end

  context 'ccmcc application' do
    context 'refund' do
      let(:application) { create :application, :refund, office: ccmcc, fee: 5000, amount_to_pay: 0 }

      it { expect(ccmcc_check_rules.rule_applies?).to be true }
    end

    describe '5k rule' do
      it { expect(ccmcc_check_rules.rule_applies?).to be true }

      it 'has the frequency of 1 - as every application applies' do
        ccmcc_check_rules.rule_applies?
        expect(ccmcc_check_rules.frequency).to be 1
      end

      it 'check type value' do
        ccmcc_check_rules.rule_applies?
        expect(ccmcc_check_rules.check_type).to eq('over 5 thousand')
      end

      it 'check query_type' do
        ccmcc_check_rules.rule_applies?
        expect(ccmcc_check_rules.query_type).to eq(:all)
      end

      context 'way over 5 thousand' do
        let(:application) { create :application, office: ccmcc, fee: 100000, amount_to_pay: 0 }
        it { expect(ccmcc_check_rules.rule_applies?).to be true }

        it 'has the frequency of 1 - as every application applies' do
          ccmcc_check_rules.rule_applies?
          expect(ccmcc_check_rules.frequency).to be 1
        end
      end

      context 'part payment' do
        let(:application) { create :application, office: ccmcc, fee: 5100, amount_to_pay: 100 }
        it { expect(ccmcc_check_rules.rule_applies?).to be true }

        it 'has the frequency of 1 - as every application applies' do
          ccmcc_check_rules.rule_applies?
          expect(ccmcc_check_rules.frequency).to be 1
        end
      end
    end

    describe 'check on £1000 to £4999' do
      context 'refund' do
        let(:application) { create :application, :refund, office: ccmcc, fee: 1000, amount_to_pay: 0 }

        it { expect(ccmcc_check_rules.rule_applies?).to be true }

        it 'check query_type' do
          ccmcc_check_rules.rule_applies?
          expect(ccmcc_check_rules.query_type).to be CCMCCEvidenceCheckRules::QUERY_REFUND
        end

        it 'has the frequency of 2 - as 50 percent' do
          ccmcc_check_rules.rule_applies?
          expect(ccmcc_check_rules.frequency).to be 2
        end

        it 'check type value' do
          ccmcc_check_rules.rule_applies?
          expect(ccmcc_check_rules.check_type).to eq('between 1 and 5 thousand refund')
        end

        context 'part payment' do
          let(:application) { create :application, :refund, office: ccmcc, fee: 1100, amount_to_pay: 100 }
          it { expect(ccmcc_check_rules.rule_applies?).to be true }

          it 'has the frequency of 2' do
            ccmcc_check_rules.rule_applies?
            expect(ccmcc_check_rules.frequency).to be 2
          end
        end
      end

      context 'non refund' do
        context '£1000' do
          let(:application) { create :application, office: ccmcc, fee: 1000, amount_to_pay: 0 }

          it { expect(ccmcc_check_rules.rule_applies?).to be true }

          it 'has the frequency of 4 - as 25 percent' do
            ccmcc_check_rules.rule_applies?
            expect(ccmcc_check_rules.frequency).to be 4
          end

          it 'check type value' do
            ccmcc_check_rules.rule_applies?
            expect(ccmcc_check_rules.check_type).to eq('between 1 and 5 thousand')
          end

          it 'check query_type' do
            ccmcc_check_rules.rule_applies?
            expect(ccmcc_check_rules.query_type).to be nil
          end
        end

        context '£4999' do
          let(:application) { create :application, office: ccmcc, fee: 4999, amount_to_pay: 0 }
          it { expect(ccmcc_check_rules.rule_applies?).to be true }

          it 'has the frequency of 4 - as 25 percent' do
            ccmcc_check_rules.rule_applies?
            expect(ccmcc_check_rules.frequency).to be 4
          end

          it 'check type value' do
            ccmcc_check_rules.rule_applies?
            expect(ccmcc_check_rules.check_type).to eq('between 1 and 5 thousand')
          end
        end

        context 'part payment' do
          let(:application) { create :application, office: ccmcc, fee: 5099, amount_to_pay: 100 }
          it { expect(ccmcc_check_rules.rule_applies?).to be true }

          it 'has the frequency of 4' do
            ccmcc_check_rules.rule_applies?
            expect(ccmcc_check_rules.frequency).to be 4
          end
        end
      end
    end
  end

  describe 'check on £100 to £999' do
    context 'refund' do
      let(:application) { create :application, :refund, office: ccmcc, fee: 999, amount_to_pay: 0 }

      it { expect(ccmcc_check_rules.rule_applies?).to be true }

      it 'check query_type' do
        ccmcc_check_rules.rule_applies?
        expect(ccmcc_check_rules.query_type).to be CCMCCEvidenceCheckRules::QUERY_REFUND
      end

      it 'has the frequency of 4 - as 25 percent' do
        ccmcc_check_rules.rule_applies?
        expect(ccmcc_check_rules.frequency).to be 4
      end

      it 'check type value' do
        ccmcc_check_rules.rule_applies?
        expect(ccmcc_check_rules.check_type).to eq('between 100 and 999 refund')
      end

      context 'part payment' do
        let(:application) { create :application, :refund, office: ccmcc, fee: 1099, amount_to_pay: 100 }
        it { expect(ccmcc_check_rules.rule_applies?).to be true }

        it 'has the frequency of 4' do
          ccmcc_check_rules.rule_applies?
          expect(ccmcc_check_rules.frequency).to be 4
        end
      end

    end

    context 'non refund' do
      let(:application) { create :application, office: ccmcc, fee: 999, amount_to_pay: 0 }

      it { expect(ccmcc_check_rules.rule_applies?).to be true }

      it 'check query_type' do
        ccmcc_check_rules.rule_applies?
        expect(ccmcc_check_rules.query_type).to be nil
      end

      it 'has the frequency of 10 - as 10 percent' do
        ccmcc_check_rules.rule_applies?
        expect(ccmcc_check_rules.frequency).to be 10
      end

      it 'check type value' do
        ccmcc_check_rules.rule_applies?
        expect(ccmcc_check_rules.check_type).to eq('between 100 and 999 non refund')
      end

      context 'part payment' do
        let(:application) { create :application, office: ccmcc, fee: 1099, amount_to_pay: 100 }
        it { expect(ccmcc_check_rules.rule_applies?).to be true }

        it 'has the frequency of 10' do
          ccmcc_check_rules.rule_applies?
          expect(ccmcc_check_rules.frequency).to be 10
        end
      end
    end
  end

  describe 'under 100' do
    context 'refund' do
      let(:application) { create :application, office: ccmcc, fee: 99, amount_to_pay: 0 }
      it { expect(ccmcc_check_rules.rule_applies?).to be true }

      it 'check query_type' do
        ccmcc_check_rules.rule_applies?
        expect(ccmcc_check_rules.query_type).to be CCMCCEvidenceCheckRules::QUERY_ALL
      end

      it 'has the frequency of 50 - as 2 percent' do
        ccmcc_check_rules.rule_applies?
        expect(ccmcc_check_rules.frequency).to be 50
      end

      it 'check type value' do
        ccmcc_check_rules.rule_applies?
        expect(ccmcc_check_rules.check_type).to eq('under 100')
      end

      context 'part payment' do
        let(:application) { create :application, :refund, office: ccmcc, fee: 199, amount_to_pay: 100 }
        it { expect(ccmcc_check_rules.rule_applies?).to be true }

        it 'has the frequency of 50' do
          ccmcc_check_rules.rule_applies?
          expect(ccmcc_check_rules.frequency).to be 50
        end
      end

    end

    context 'not a refund' do
      let(:application) { create :application, :refund, office: ccmcc, fee: 99, amount_to_pay: 0 }
      it { expect(ccmcc_check_rules.rule_applies?).to be true }

      it 'check query_type' do
        ccmcc_check_rules.rule_applies?
        expect(ccmcc_check_rules.query_type).to be CCMCCEvidenceCheckRules::QUERY_ALL
      end

      it 'has the frequency of 50 - as 2 percent' do
        ccmcc_check_rules.rule_applies?
        expect(ccmcc_check_rules.frequency).to be 50
      end

      it 'check type value' do
        ccmcc_check_rules.rule_applies?
        expect(ccmcc_check_rules.check_type).to eq('under 100')
      end

      context 'part payment' do
        let(:application) { create :application, office: ccmcc, fee: 199, amount_to_pay: 100 }
        it { expect(ccmcc_check_rules.rule_applies?).to be true }

        it 'has the frequency of 50' do
          ccmcc_check_rules.rule_applies?
          expect(ccmcc_check_rules.frequency).to be 50
        end
      end
    end
  end

end
