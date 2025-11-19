require 'rails_helper'

RSpec.describe Forms::Application::Benefit do
  subject { described_class.new(hash) }

  params_list = [:benefits]

  let(:hash) { {} }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validations' do
    let(:benefit) { described_class.new(hash) }

    describe 'benefits' do
      context 'when true' do
        before { benefit[:benefits] = true }

        it { expect(benefit.valid?).to be true }
      end

      context 'when false' do
        before { benefit[:benefits] = false }

        it { expect(benefit.valid?).to be true }
      end

      context 'when not a boolean value' do
        before { benefit[:benefits] = 'string' }

        it { expect(benefit.valid?).to be false }
      end
    end
  end

  describe '#save' do
    subject(:form) { described_class.new(application) }

    subject(:form_update) do
      form.update(attributes)
      form.save
    end

    let(:attributes) { { benefits: benefits } }
    let(:application) { create(:application, application_type: nil, dependents: false, benefits: nil, outcome: nil, income: '1000', income_kind: 'Wages', income_period: 'last month') }

    context 'when the attributes are correct' do
      let(:benefits) { false }

      it { is_expected.to be true }

      describe 'application is updated' do
        let(:benefit_check) { nil }

        before do
          benefit_check
          form_update
          application.reload
        end

        context 'when benefits is true' do
          let(:benefits) { true }

          it 'updates the application attribute' do
            expect(application.benefits).to be true
          end

          it 'sets application type to benefit' do
            expect(application.application_type).to eql 'benefit'
          end

          it 'sets dependents to nil' do
            expect(application.dependents).to be_nil
          end

          it 'clears income attributes' do
            expect(application.income).to be_nil
            expect(application.income_period).to be_nil
            expect(application.income_kind).to be_nil
          end

          context 'when benefit check has been done already' do
            let(:benefit_check) { create(:benefit_check, :yes_result, applicationable: application) }

            it 'updates outcome based on the result' do
              expect(application.outcome).to eql 'full'
            end
          end

          context 'when benefit check has not been done' do
            it 'keeps outcome unchanged' do
              expect(application.outcome).to be_nil
            end
          end

          context 'when benefit check exists with negative result' do
            let(:benefit_check) { create(:benefit_check, applicationable: application, dwp_result: 'No') }

            it 'updates outcome to none' do
              expect(application.outcome).to eql 'none'
            end
          end
        end

        context 'when benefits is false' do
          it 'updates the application attribute' do
            expect(application.benefits).to be false
          end

          it 'sets application type to income' do
            expect(application.application_type).to eql 'income'
          end

          it 'keeps the income attributes' do
            expect(application.income).to be 1000
            expect(application.income_period).to eql 'last month'
            expect(application.income_kind).to eql 'Wages'
          end

          context 'when benefit check exists with outcome' do
            let(:benefit_check) { create(:benefit_check, :yes_result, applicationable: application) }

            before do
              benefit_check
              form_update
              application.reload
            end

            it 'updates outcome based on the benefit check' do
              expect(application.outcome).to eql 'full'
            end
          end
        end
      end
    end

    context 'when the attributes are incorrect' do
      let(:benefits) { nil }

      it { is_expected.to be false }
    end
  end
end
