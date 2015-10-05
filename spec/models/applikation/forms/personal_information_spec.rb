require 'rails_helper'

RSpec.describe Applikation::Forms::PersonalInformation do
  params_list = %i[last_name date_of_birth married title first_name ni_number]

  let(:personal_information) { attributes_for :personal_information }
  subject { described_class.new(personal_information) }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_length_of(:last_name).is_at_least(2) }

    describe 'date_of_birth' do
      it { is_expected.to validate_presence_of(:date_of_birth) }

      context 'when the date_of_birth is less than minimum age allowed' do
        before { personal_information[:date_of_birth] = Time.zone.today - (described_class::MINIMUM_AGE - 1).years }

        it { expect(subject.valid?).not_to be true }
      end

      context 'when the date_of_birth exceeds maximum allowed age' do
        before { personal_information[:date_of_birth] = Time.zone.today - (described_class::MAXIMUM_AGE + 1).years }

        it { expect(subject.valid?).not_to be true }
      end

      context 'when the date_of_birth is a non date value' do
        before { personal_information[:date_of_birth] = 'some string' }

        it { expect(subject.valid?).not_to be true }
      end
    end

    describe 'married' do
      context 'when true' do
        before { personal_information[:married] = true }

        it { expect(subject.valid?).to be true }
      end

      context 'when false' do
        before { personal_information[:married] = false }

        it { expect(subject.valid?).to be true }
      end

      context 'when not a boolean value' do
        before { personal_information[:married] = 'string' }

        it { expect(subject.valid?).to be false }
      end
    end

    describe 'ni_number' do
      context 'when valid' do
        before { personal_information[:ni_number] = 'AB112233A' }

        it 'passes validation' do
          expect(subject.valid?).to be true
        end
      end

      context 'when blank' do
        before { subject.ni_number = '' }

        it 'passes validation' do
          expect(subject.valid?).to be true
        end
      end

      context 'when invalid' do
        before { subject.ni_number = 'FOOBAR' }

        it 'passes validation' do
          expect(subject.valid?).to be false
        end
      end

      context 'when passed in as lower case' do
        before { subject.ni_number = 'ab112233a' }

        it 'up-cases it to pass the validation' do
          expect(subject.valid?).to be true
        end
      end

      context 'when white space is passed in' do
        before { subject.ni_number = ' AB112233A' }

        it 'strips it away to pass the validation' do
          expect(subject.valid?).to be true
        end
      end
    end
  end

  describe 'when Application object is passed in' do
    let(:application) { create :application }
    let(:form) { described_class.new(application) }

    params_list.each do |attr_name|
      it "assigns #{attr_name}" do
        expect(form.send(attr_name)).to eq application.send(attr_name)
      end
    end
  end

  describe 'when a Hash is passed in' do
    let(:hash) { attributes_for :full_personal_information }
    let(:form) { described_class.new(hash) }
    most_attribs = params_list.reject { |k, _| k == :date_of_birth }

    most_attribs.each do |attr_name|
      it "assigns #{attr_name}" do
        expect(form.send(attr_name)).to eq hash[attr_name]
      end
    end

    it 'assign date_of_birth attribute' do
      expect(form.date_of_birth).to eq hash[:date_of_birth].to_date
    end
  end
end
