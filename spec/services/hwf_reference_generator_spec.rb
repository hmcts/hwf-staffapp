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

    # rubocop:disable RSpec/SubjectStub
    context 'when the generated reference number already exists' do
      before do
        create(:online_application, reference: 'hwf-collision')
        allow(generator).to receive(:reference_string).and_return('hwf-collision')
        allow(generator).to receive(:reference_string).and_return('hwf-no-collision')
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
    # rubocop:enable RSpec/SubjectStub

    context 'when the application is benefits' do
      subject(:generator) { described_class.new(true) }
      it 'keeps generating until there is no collision' do
        expect(attributes[:reference]).to include('HWF-Z')
      end
    end

    context 'when the application is not benefits' do
      subject(:generator) { described_class.new(false) }
      it 'keeps generating until there is no collision' do
        expect(attributes[:reference]).to include('HWF-A')
      end
    end

    describe 'raise error when there are too many references' do
      let(:count_result_over) { instance_double(ActiveRecord::Relation, count: 1679617) }
      let(:count_result_under) { instance_double(ActiveRecord::Relation, count: 1679615) }

      context 'for normal application' do
        before do
          allow(OnlineApplication).to receive(:where).with('reference like ?', 'HWF-Z%').and_return(count_result_under)
          allow(OnlineApplication).to receive(:where).with('reference like ?', 'HWF-A%').and_return(count_result_over)
        end
        it 'raise error' do
          expect { generator }.to raise_error(HwfReferenceGenerator::HwfReferenceDuplicationWarning)
        end
      end
      context 'for benefit application' do
        before do
          allow(OnlineApplication).to receive(:where).with('reference like ?', 'HWF-Z%').and_return(count_result_over)
          allow(OnlineApplication).to receive(:where).with('reference like ?', 'HWF-A%').and_return(count_result_under)
        end
        it 'raise error' do
          expect { generator }.to raise_error(HwfReferenceGenerator::HwfReferenceDuplicationWarning)
        end
      end
    end
  end
end
