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

      it 'is 11 characters long' do
        expect(subject.length).to eql 11
      end
    end

    context 'when the generated reference number already exists', focus: true do
      before do
        create(:online_application, reference: 'collision')
        expect(generator).to receive(:reference_string).and_return('collision', 'no-collision')
      end

      it 'keeps generating until there is no collision' do
        expect(attributes[:reference]).to eql('no-collision')
      end
    end
  end
end
