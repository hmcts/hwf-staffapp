require 'rails_helper'

RSpec.describe Forms::Evidence::HmrcCheck do
  subject(:form) { described_class.new(HmrcCheck.new(evidence_check: evidence)) }
  let(:application) { build(:application, created_at: '15.3.2021', children: children, income_period: income_period) }
  let(:evidence) { build(:evidence_check, application: application) }
  let(:income_period) { Application::INCOME_PERIOD[:last_month] }
  let(:children) { 0 }
  let(:params) {
    {
      "from_date_day" => from_date_day,
      "from_date_month" => from_date_month,
      "from_date_year" => from_date_year,
      "to_date_day" => to_date_day,
      "to_date_month" => to_date_month,
      "to_date_year" => to_date_year,
      "additional_income_amount" => additional_income_amount,
      "additional_income" => additional_income,
      "user_id" => 256
    }
  }

  let(:from_date_day) { '1' }
  let(:from_date_month) { '5' }
  let(:from_date_year) { '2024' }
  let(:to_date_day) { '31' }
  let(:to_date_month) { '5' }
  let(:to_date_year) { '2024' }
  let(:additional_income_amount) { 1 }
  let(:additional_income) { nil }

  describe 'validation' do
    before do
      form.update(params)
    end

    subject { form.valid? }

    context 'when the from date and to date is valid' do
      it { is_expected.to be true }
    end

    context 'when the additional_income is' do
      describe 'false' do
        let(:additional_income) { false }
        let(:from_date_day) { '' }
        it { is_expected.to be true }
      end

      describe 'true' do
        let(:additional_income) { true }
        let(:from_date_day) { '' }
        it { is_expected.to be true }
      end

      describe 'nil' do
        let(:additional_income) { nil }
        let(:from_date_day) { '' }
        it { is_expected.to be false }
      end
    end

    describe 'month range' do
      context 'from_date' do
        context 'day' do
          let(:from_date_day) { '22' }
          it { is_expected.to be false }
        end
        context 'month' do
          let(:from_date_month) { '1' }
          it { is_expected.to be false }
        end
        context 'year' do
          let(:from_date_year) { '2020' }
          it { is_expected.to be false }

          it 'message with correct range' do
            form.valid?
            message = 'Enter a calendar month date range'
            expect(form.errors[:date_range]).to eq [message]
          end
        end
      end

      context 'to_date' do
        context 'day' do
          let(:to_date_day) { '22' }
          it { is_expected.to be false }
        end
        context 'month' do
          let(:to_date_month) { '3' }
          it { is_expected.to be false }
        end
        context 'year' do
          let(:to_date_year) { '2022' }
          it { is_expected.to be false }
        end
      end
    end

    context 'from_date' do
      it "has correct format" do
        form.valid?
        expect(form.from_date).to eql('2024-05-01')
      end

      context 'year is not valid' do
        let(:from_date_year) { '' }

        it { is_expected.to be false }
      end

      context 'month is blank' do
        let(:from_date_month) { '' }

        it { is_expected.to be false }
      end

      context 'month is not valid' do
        let(:from_date_month) { '22' }

        it { is_expected.to be false }
      end

      context 'day is blank' do
        let(:from_date_day) { '' }

        it { is_expected.to be false }
      end

      context 'day is nil' do
        let(:from_date_day) { nil }

        it { is_expected.to be false }
      end

      context 'day is not valid' do
        let(:from_date_day) { 'dd' }

        it { is_expected.to be false }
      end
    end

    context 'to_date' do
      it "has correct format" do
        form.valid?
        expect(form.to_date).to eql('2024-05-31')
      end

      context 'year is not valid' do
        let(:to_date_year) { '' }

        it { is_expected.to be false }
      end

      context 'month is blank' do
        let(:to_date_month) { '' }

        it { is_expected.to be false }
      end

      context 'month is not valid' do
        let(:to_date_month) { '21' }

        it { is_expected.to be false }
      end

      context 'day is blank' do
        let(:to_date_day) { '' }

        it { is_expected.to be false }
      end

      context 'day is nil' do
        let(:to_date_day) { nil }

        it { is_expected.to be false }
      end

      context 'day is not valid' do
        let(:to_date_day) { 'dd' }

        it { is_expected.to be false }
      end
    end

    context 'validate date based on income_period' do
      context 'last_month' do
        let(:income_period) { Application::INCOME_PERIOD[:last_month] }
        it { is_expected.to be true }
      end

      context 'three_months not valid' do
        let(:income_period) { Application::INCOME_PERIOD[:average] }
        it { is_expected.to be false }
      end

      context 'three_months valid' do
        let(:income_period) { Application::INCOME_PERIOD[:average] }
        let(:from_date_day) { '1' }
        let(:from_date_month) { '2' }
        let(:from_date_year) { '2021' }
        let(:to_date_day) { '30' }
        let(:to_date_month) { '4' }
        let(:to_date_year) { '2021' }

        it { is_expected.to be true }
      end

      context 'two monts imvalid' do
        let(:income_period) { Application::INCOME_PERIOD[:average] }
        let(:from_date_day) { '1' }
        let(:from_date_month) { '2' }
        let(:from_date_year) { '2021' }
        let(:to_date_day) { '31' }
        let(:to_date_month) { '3' }
        let(:to_date_year) { '2021' }

        it { is_expected.to be false }
      end
    end
  end

  context 'load_additional_income_from_benefits' do

    subject(:form) { described_class.new(HmrcCheck.new(evidence_check: evidence, request_params: { date_range: { from: from_range, to: to_range } })) }

    let(:additional_income_amount) { nil }
    let(:additional_income) { nil }

    before do
      form.update(params)
      form.valid?
    end

    context 'no child' do
      let(:children) { nil }
      let(:additional_income) { false }
      let(:from_range) { '2024-02-01' }
      let(:to_range) { '2024-02-28' }

      it 'additional_income' do
        form.load_additional_income_from_benefits
        expect(form.additional_income_amount).to be_nil
        expect(form.additional_income).to be false
      end
    end

    context '1 child' do
      let(:children) { 1 }

      context '24/25 year' do
        let(:from_range) { '2024-02-01' }
        let(:to_range) { '2024-02-28' }

        it 'additional_income' do
          form.load_additional_income_from_benefits
          expect(form.additional_income_amount).to eq 102
          expect(form.additional_income).to be true
        end
      end

      context '25/25 3 months average' do
        let(:from_range) { '2024-01-01' }
        let(:to_range) { '2024-03-31' }

        it 'additional_income' do
          form.load_additional_income_from_benefits
          expect(form.additional_income_amount).to eq 102
          expect(form.additional_income).to be true
        end
      end

      context '24/25 and 25/26 3 months average - 1 month overlap' do
        let(:from_range) { '2025-02-01' }
        let(:to_range) { '2025-04-30' }

        it 'additional_income' do
          form.load_additional_income_from_benefits
          expect(form.additional_income_amount).to eq 103
          expect(form.additional_income).to be true
        end
      end

      context '24/25 and 25/26 3 months average - 2 months overlap' do
        let(:from_range) { '2025-03-01' }
        let(:to_range) { '2025-05-31' }

        it 'additional_income' do
          form.load_additional_income_from_benefits
          expect(form.additional_income_amount).to eq 103
          expect(form.additional_income).to be true
        end
      end

      context '24/25 financial year' do
        let(:from_range) { '2025-06-01' }
        let(:to_range) { '2025-06-30' }

        it 'additional_income' do
          form.load_additional_income_from_benefits
          expect(form.additional_income_amount).to eq 104
          expect(form.additional_income).to be true
        end
      end
    end

    context '2 children' do
      let(:children) { 2 }

      context '25/26 financial year' do
        let(:from_range) { '2025-06-01' }
        let(:to_range) { '2025-06-30' }

        it 'additional_income' do
          form.load_additional_income_from_benefits
          expect(form.additional_income_amount).to eq 173
          expect(form.additional_income).to be true
        end
      end

      context '24/25 financial year' do
        let(:from_range) { '2024-02-01' }
        let(:to_range) { '2024-02-28' }

        it 'additional_income' do
          form.load_additional_income_from_benefits
          expect(form.additional_income_amount).to eq 170
          expect(form.additional_income).to be true
        end
      end

      context '24/25 and 25/26 3 months average - 1 month overlap' do
        let(:from_range) { '2025-02-01' }
        let(:to_range) { '2025-04-30' }

        it 'additional_income' do
          form.load_additional_income_from_benefits
          expect(form.additional_income_amount).to eq 171
          expect(form.additional_income).to be true
        end
      end

      context '24/25 and 25/26 3 months average - 2 months overlap' do
        let(:from_range) { '2025-03-01' }
        let(:to_range) { '2025-05-31' }

        it 'additional_income' do
          form.load_additional_income_from_benefits
          expect(form.additional_income_amount).to eq 172
          expect(form.additional_income).to be true
        end
      end
    end

    context '3 children' do
      let(:children) { 3 }
      let(:from_range) { '2025-02-01' }
      let(:to_range) { '2025-02-28' }

      it 'additional_income' do
        form.load_additional_income_from_benefits
        expect(form.additional_income_amount).to eq 238
        expect(form.additional_income).to be true
      end
    end

    context '4 children' do
      let(:children) { 4 }
      let(:from_range) { '2025-02-01' }
      let(:to_range) { '2025-02-28' }

      it 'additional_income' do
        form.load_additional_income_from_benefits
        expect(form.additional_income_amount).to eq 305
        expect(form.additional_income).to be true
      end
    end

    context '7 children' do
      let(:children) { 7 }
      let(:from_range) { '2025-01-01' }
      let(:to_range) { '2025-03-31' }

      it 'additional_income' do
        form.load_additional_income_from_benefits
        expect(form.additional_income_amount).to eq 509
        expect(form.additional_income).to be true
      end
    end

    context '8 children 24/25' do
      let(:children) { 8 }
      let(:from_range) { '2024-01-01' }
      let(:to_range) { '2024-03-31' }

      it 'additional_income' do
        form.load_additional_income_from_benefits
        expect(form.additional_income_amount).to eq 577
        expect(form.additional_income).to be true
      end
    end

    context '9 children 24/25' do
      let(:children) { 9 }
      let(:from_range) { '2025-01-01' }
      let(:to_range) { '2025-03-31' }

      it 'additional_income' do
        form.load_additional_income_from_benefits
        expect(form.additional_income_amount).to eq 644
        expect(form.additional_income).to be true
      end

      context '24/25 and 25/26 3 months average - 1 month overlap' do
        let(:from_range) { '2025-02-01' }
        let(:to_range) { '2025-04-30' }

        it 'additional_income' do
          form.load_additional_income_from_benefits
          expect(form.additional_income_amount).to eq 648
          expect(form.additional_income).to be true
        end
      end

      context '24/25 and 25/26 3 months average - 2 months overlap' do
        let(:from_range) { '2025-03-01' }
        let(:to_range) { '2025-05-31' }

        it 'additional_income' do
          form.load_additional_income_from_benefits
          expect(form.additional_income_amount).to eq 652
          expect(form.additional_income).to be true
        end
      end

    end

    context 'don not ovrride existing value' do
      let(:children) { 2 }
      let(:from_range) { '2025-01-01' }
      let(:to_range) { '2025-03-31' }

      it 'additional_income' do
        form.additional_income_amount = 10
        form.load_additional_income_from_benefits
        expect(form.additional_income_amount).to eq 10
      end
    end
  end

  context 'store' do
    subject(:form) { described_class.new(hmrc_check) }
    let(:hmrc_check) { HmrcCheck.create(evidence_check: evidence) }

    it 'additional_income' do
      form.additional_income_amount = 123
      form.additional_income = true
      form.save
      expect(hmrc_check.additional_income).to eq 123
    end
  end
end
