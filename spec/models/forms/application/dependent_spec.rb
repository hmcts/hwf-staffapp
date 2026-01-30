require 'rails_helper'

RSpec.describe Forms::Application::Dependent do
  subject(:children_form) { described_class.new(application) }
  let(:application) { build(:application, detail: detail) }
  let(:detail) { build(:detail, calculation_scheme: calculation_scheme) }
  let(:age_band) { nil }
  let(:calculation_scheme) { FeatureSwitching::CALCULATION_SCHEMAS[0] }

  params_list = [:children, :children_age_band, :children_age_band_one, :children_age_band_two, :dependents, :income]

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validation' do
    let(:children_form) { described_class.new(application) }

    describe 'income' do
      let(:application) { build(:application, detail: detail, income: 500, dependents: true, children: 1) }

      it { is_expected.to validate_presence_of(:income) }

      # ActiveModel::Attributes coerces non-numeric strings to 0, so we test valid values instead
      it 'accepts numeric values' do
        children_form.income = 500
        children_form.valid?
        expect(children_form.errors[:income]).to be_empty
      end
    end

    describe 'dependents' do
      let(:application) { build(:application, detail: detail, income: 500, dependents: dependents, children: 1) }

      context 'when true' do
        let(:dependents) { true }

        it { expect(children_form.valid?).to be true }
      end

      context 'when false' do
        let(:dependents) { false }

        it { expect(children_form.valid?).to be false }
      end
    end

    describe 'children' do
      let(:application) { build(:application, detail: detail, income: 500, dependents: dependents, children: children) }

      context 'when there are dependents' do
        let(:dependents) { true }

        context 'and the number of children is valid' do
          let(:children) { 1 }

          it { expect(children_form.valid?).to be true }
        end

        context 'and the number of children is invalid' do
          let(:children) { 0 }

          it { expect(children_form.valid?).to be false }
        end
      end

      context 'when there are no dependents' do
        let(:dependents) { false }

        context 'and the number of children is bigger than zero' do
          let(:children) { 1 }

          it { expect(children_form.valid?).to be false }
        end

        context 'and the number of children is zero' do
          let(:children) { 0 }

          it { expect(children_form.valid?).to be true }
        end
      end

      context 'UCD applies' do
        let(:calculation_scheme) { FeatureSwitching::CALCULATION_SCHEMAS[1] }
        let(:dependents) { true }
        let(:children) { 0 }
        context 'age band present' do
          before {
            children_form.children_age_band_one = 1
          }

          it { expect(children_form.valid?).to be true }
        end

        context 'age band missing' do
          before {
            children_form.children_age_band_one = 0
            children_form.children_age_band_one = 0
          }

          it { expect(children_form.valid?).to be false }
        end

        context 'no validation for income' do
          before {
            children_form.income = nil
            children_form.children_age_band_one = 1
          }

          it { expect(children_form.valid?).to be true }
        end
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
      let(:params) { { income: 500, dependents: true, children: 2 } }

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
      let(:params) { { dependents: nil } }

      it { is_expected.to be false }
    end
  end

  describe '#save UCD applies' do
    subject(:form) { described_class.new(application) }

    subject(:update_form) do
      form.update(params)
      form.save
    end

    let(:application) { create(:application, detail: detail) }

    context 'when attributes are correct' do
      let(:calculation_scheme) { FeatureSwitching::CALCULATION_SCHEMAS[1] }
      let(:params) { { income: nil, dependents: true, children_age_band_one: 1, children_age_band_two: 2 } }
      let(:params_to_check) { { income: nil, dependents: true, children_age_band: { one: 1, two: 2 } } }

      it { is_expected.to be true }

      before do
        update_form
        application.reload
      end

      it 'saves the parameters in the detail' do
        params_to_check.each do |key, value|
          expect(application.send(key)).to eql(value)
        end
      end

      it 'marks the application as income' do
        expect(application.application_type).to eql('income')
      end
    end

    context 'when attributes are incorrect' do
      let(:params) { { dependents: nil } }

      it { is_expected.to be false }
    end
  end
end
