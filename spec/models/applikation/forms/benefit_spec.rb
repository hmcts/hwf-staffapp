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
    let(:application) { create :application, benefits: nil }
    subject(:form) { described_class.new(application) }

    subject do
      form.update_attributes(attributes)
      form.save
    end

    context 'when the attributes are correct' do
      let(:attributes) { { benefits: false } }

      it { is_expected.to be true }

      it 'saves the attributes to the application' do
        subject
        application.reload

        expect(application.benefits).to eql(false)
      end
    end

    context 'when the attributes are incorrect' do
      let(:attributes) { { benefits: nil } }

      it { is_expected.to be false }
    end
  end
end
