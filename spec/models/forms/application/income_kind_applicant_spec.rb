require 'rails_helper'

RSpec.describe Forms::Application::IncomeKindApplicant do
  subject(:income_kind_form) { described_class.new(application) }
  let(:application) { build(:application) }

  params_list = [:income_kind, :income_kind_applicant]

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validation' do
    let(:income_kind_form) { described_class.new(application) }

    describe 'income' do
      let(:application) { build(:application) }

      it { is_expected.to validate_presence_of(:income_kind_applicant) }
    end

    describe '#none_of_above_selected' do
      subject(:update_form) do
        income_kind_form.update(params)
        income_kind_form.valid?
      end

      let(:application) { build(:application) }

      before do
        update_form
      end
      context 'when attributes are correct' do
        let(:params) { { income_kind_applicant: ['none_of_the_above'] } }

        it { is_expected.to be true }
      end

      context 'when user picks none of the above and more income kinds' do
        let(:params) { { income_kind_applicant: ['wage', 'none_of_the_above'] } }

        it { is_expected.to be false }

        it { expect(income_kind_form.errors[:income_kind_applicant]).to include "Deselect 'None of the above' if you would like to select any of the other options" }
      end
    end

    describe '#child_benefit_selected' do
      subject(:update_form) do
        income_kind_form.update(params)
        income_kind_form.valid?
      end

      before do
        update_form
      end
      context 'when children are selected' do
        let(:params) { { income_kind_applicant: ['child_benefit'] } }
        let(:application) { create(:application, children: 1) }

        it { is_expected.to be true }
      end

      context 'when no children are selected' do
        let(:params) { { income_kind_applicant: ['child_benefit'] } }
        let(:application) { create(:application, children: 0) }

        it { is_expected.to be false }
        it { expect(income_kind_form.errors[:income_kind_applicant]).to include "No children declared on application therefore cannot select Child Benefit. Please return application for clarification" }
      end
    end
  end

  describe '#save' do
    subject(:form) { described_class.new(application) }

    subject(:update_form) do
      form.update(params)
      form.save
    end

    let(:application) { create(:application, income_kind: { applicant: ['test'], partner: ['test2'] }) }

    context 'when attributes are correct' do
      let(:params) { { income_kind_applicant: ['wage'] } }

      it { is_expected.to be true }

      before do
        update_form
        application.reload
      end

      it 'saves the parameters in the detail' do
        expect(application.income_kind).to eq({ applicant: ['wage'], partner: ['test2'] })
      end
    end

    context 'when attributes are incorrect' do
      let(:params) { { income_kind_applicant: nil } }

      it { is_expected.to be false }
    end
  end

end
