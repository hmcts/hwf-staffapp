require 'rails_helper'

RSpec.describe HwfReferenceGenerator, type: :service do
  subject(:generator) { described_class.new }

  describe '#attributes' do

    subject(:attributes) { generator.attributes }

    it { is_expected.to be_a Hash }
    it { is_expected.to include :reference }

    describe 'reference' do
      subject(:reference) { attributes[:reference] }

      it { is_expected.to start_with 'HWF-' }

      it 'is 10 characters long' do
        expect(subject.length).to eql 11
      end
    end
  end
end
