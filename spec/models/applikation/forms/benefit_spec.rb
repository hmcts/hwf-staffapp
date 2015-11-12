require 'rails_helper'

RSpec.describe Applikation::Forms::Benefit do
  params_list = %i[benefits]

  let(:hash) { {} }

  subject { described_class.new(hash) }

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
    let(:attributes) { { benefits: benefits } }
    let(:application) { create :application, application_type: nil, dependents: false, benefits: nil, outcome: nil }
    subject(:form) { described_class.new(application) }

    subject do
      form.update_attributes(attributes)
      form.save
    end

    context 'when the attributes are correct' do
      let(:benefits) { false }

      it { is_expected.to be true }

      describe 'application is updated' do
        let(:benefit_check) { nil }

        before do
          benefit_check
          subject
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
            expect(application.dependents).to be nil
          end

          context 'when benefit check has been done already' do
            let(:benefit_check) { create :benefit_check, :yes_result, application: application }

            it 'updates outcome based on the result' do
              expect(application.outcome).to eql 'full'
            end
          end

          context 'when benefit check has not been done' do
            it 'keeps outcome unchanged' do
              expect(application.outcome).to be nil
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
        end
      end
    end

    context 'when the attributes are incorrect' do
      let(:benefits) { nil }

      it { is_expected.to be false }
    end
  end
end
