require 'rails_helper'

RSpec.describe EvidenceCheckHelper do
  let(:application) { build(:application, :waiting_for_evidence_state, evidence_check: evidence, income: income1) }
  let(:evidence) { build(:evidence_check, income: income2) }
  let(:income1) { nil }
  let(:income2) { nil }

  describe '#income_increase?' do
    context 'income is nil' do
      it 'returns false' do
        expect(income_increase?(application)).to be_falsey
      end
    end

    context 'original income is higher then new one' do
      let(:income1) { 2000 }
      let(:income2) { 1999 }

      it 'returns false' do
        expect(income_increase?(application)).to be_falsey
      end
    end

    context 'original income is lower then new one' do
      let(:income1) { 2000 }
      let(:income2) { 2001 }

      it 'returns false' do
        expect(income_increase?(application)).to be_truthy
      end
    end

    context 'original income is same as the new one' do
      let(:income1) { 2000 }
      let(:income2) { 2000 }

      it 'returns false' do
        expect(income_increase?(application)).to be_falsey
      end
    end
  end

  describe 'display_evidence_section?' do
    let(:application) { build(:application, income_kind: income_kind) }
    let(:income_kind) { {} }

    context 'No match for income kind' do
      let(:income_kind) { { applicant: ['Wage'] } }
      it { expect(display_evidence_section?(application, 'wages')).to be false }
    end

    context 'No match for section name' do
      let(:income_kind) { { applicant: ['Wages'] } }
      it { expect(display_evidence_section?(application, 'wage')).to be false }
    end

    ["Wages before tax and National Insurance are taken off", "Net profits from self employment", "Pensions (state, work, private)",
     "Pensions (state, work, private, pension credit (savings credit))"].each do |income_kind_value|
      context 'Wages' do
        let(:income_kind) { { applicant: [income_kind_value] } }
        it { expect(display_evidence_section?(application, 'wages')).to be true }

        context 'partner' do
          let(:income_kind) { { applicant: ['Test'], partner: [income_kind_value] } }
          it { expect(display_evidence_section?(application, 'wages')).to be true }
        end
      end
    end

    context 'Maintenance payments' do
      let(:income_kind) { { applicant: ['Maintenance payments'] } }
      it { expect(display_evidence_section?(application, 'child_maintenance')).to be true }
    end

    ["Working Tax Credit", "Child Tax Credit", "Contribution-based Jobseekers Allowance (JSA)",
     "Contribution-based Employment and Support Allowance (ESA)", "Universal Credit", "Pensions (state, work, private)",
     "Pensions (state, work, private, pension credit (savings credit))"].each do |income_kind_value|
      context income_kind_value.to_s do
        let(:income_kind) { { applicant: [income_kind_value] } }
        it { expect(display_evidence_section?(application, 'benefits_and_credits')).to be true }
      end
    end

    ["Rent from anyone living with the applicant", "Rent from other properties the applicant owns",
     "Rent from anyone living with the partner", "Rent from other properties the partner owns",
     "Rent from anyone living with you", "Rent from other properties you own"].each do |income_kind_value|
      context income_kind_value.to_s do
        let(:income_kind) { { applicant: [income_kind_value] } }
        it { expect(display_evidence_section?(application, 'rental')).to be true }
      end
    end

    ["Other income - For example, income from online selling or from dividend or interest payments", "Other income"].each do |income_kind_value|
      context income_kind_value.to_s do
        let(:income_kind) { { applicant: [income_kind_value] } }
        it { expect(display_evidence_section?(application, 'goods_selling')).to be true }
      end
    end
  end
end
