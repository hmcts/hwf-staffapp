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
        expect(reference.length).to eq 11
      end
    end

    context 'when the generated reference number already exists' do
      before do
        create(:online_application, reference: 'hwf-collision')
        allow(generator).to receive(:reference_string).and_return('hwf-collision', 'hwf-no-collision')
      end

      it 'keeps generating until there is no collision' do
        expect(attributes[:reference]).to eql('hwf-no-collision')
      end
    end

    context 'when the generated reference contains HWF more then once' do
      before do
        allow(generator).to receive(:reference_string).and_return('HWF-AHW-HWF', 'HWF-HWF-HWF', 'HWF-HWF-HWA', 'HWF-HAF-HWA')
      end

      it 'keeps generating until there is no collision' do
        expect(attributes[:reference]).to eql('HWF-HAF-HWA')
      end
    end
  end
end
