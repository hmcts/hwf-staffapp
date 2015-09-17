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

    describe 'marital status' do
      before do
        subject.last_name = 'foo'
        subject.date_of_birth = '01 01 1970'
      end

      it 'accepts true as a value' do
        subject.married = true
        expect(subject).to be_valid
      end

      it 'accepts false as a value' do
        subject.married = false
        expect(subject).to be_valid
      end

      it 'is required' do
        subject.married = nil
        expect(subject).to be_invalid
      end
    end
  end

  describe 'construct form object from application' do
    let(:form) { described_class.new(application) }

    PARAMS_LIST.each do |attr_name|
      it "assigns #{attr_name}" do
        expect(form.send(attr_name)).to eq application.send(attr_name)
      end
    end
  end
end
