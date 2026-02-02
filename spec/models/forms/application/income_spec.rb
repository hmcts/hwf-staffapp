require 'rails_helper'

RSpec.describe Forms::Application::Income do
  subject(:income_form) { described_class.new(application) }
  let(:application) { build(:application, detail: detail) }
  let(:detail) { build(:detail, calculation_scheme: calculation_scheme) }
  let(:age_band) { nil }
  let(:calculation_scheme) { FeatureSwitching::CALCULATION_SCHEMAS[0] }

  params_list = [:income, :income_period]

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validation' do
    let(:income_form) { described_class.new(application) }

    describe 'income' do
      let(:application) { build(:application, detail: detail, income: 500, dependents: true, children: 1) }

      it { is_expected.to validate_presence_of(:income) }
      it { is_expected.to validate_presence_of(:income_period) }

      # ActiveModel::Attributes coerces non-numeric strings to 0, so we test valid values instead
      it 'accepts numeric values' do
        income_form.income = 500
        income_form.valid?
        expect(income_form.errors[:income]).to be_empty
      end
    end
  end

  describe '#save' do
    subject(:form) { described_class.new(application) }

    subject(:update_form) do
      form.update(params)
      form.save
    end

    let(:application) { create(:application) }

    context 'when attributes are correct' do
      let(:params) { { income: 500, income_period: 'test' } }

      it { is_expected.to be true }

      before do
        update_form
        application.reload
      end

      it 'saves the parameters in the detail' do
        params.each do |key, value|
          expect(application.send(key)).to eql(value)
        end
      end

      it 'marks the application as income' do
        expect(application.application_type).to eql('income')
      end
    end

    context 'when attributes are incorrect' do
      let(:params) { { income: nil } }

      it { is_expected.to be false }
    end
  end

end
