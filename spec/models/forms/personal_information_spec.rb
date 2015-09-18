require 'rails_helper'

RSpec.describe Forms::PersonalDetails do
  PARAMS_LIST = %i[last_name date_of_birth married title first_name ni_number]

  let(:application) { create :application }
  subject { described_class.new(application) }

  describe 'PERMITTED_ATTRIBUTES' do
    it 'returns a list of attributes' do
      expect(described_class::PERMITTED_ATTRIBUTES).to match_array(PARAMS_LIST)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_length_of(:last_name).is_at_least(2) }

    it { is_expected.to validate_presence_of(:date_of_birth) }

    it { is_expected.to validate_presence_of(:married) }

    describe 'ni_number' do
      context 'when valid' do
        before { application.ni_number = 'AB112233A' }

        it 'passes validation' do
          expect(application.valid?).to be true
        end
      end

      context 'when blank' do
        before { application.ni_number = '' }

        it 'passes validation' do
          expect(application.valid?).to be true
        end
      end

      context 'when invalid' do
        before { application.ni_number = 'FOOBAR' }

        it 'passes validation' do
          expect(application.valid?).to be false
        end
      end
    end
  end

  describe 'when Application object is passed in' do
    let(:form) { described_class.new(application) }

    PARAMS_LIST.each do |attr_name|
      it "assigns #{attr_name}" do
        expect(form.send(attr_name)).to eq application.send(attr_name)
      end
    end
  end

  describe 'when a Hash is passed in' do
    let(:hash) { application.attributes }
    let(:form) { described_class.new(hash) }

    PARAMS_LIST.each do |attr_name|
      it "assigns #{attr_name}" do
        expect(form.send(attr_name)).to eq hash[attr_name.to_s]
      end
    end
  end
end
