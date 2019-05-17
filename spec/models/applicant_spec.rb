require 'rails_helper'

RSpec.describe Applicant, type: :model do
  let(:application) { build_stubbed(:application) }
  let(:applicant) { build :applicant, application: application }

  it { is_expected.to validate_presence_of(:application) }

  describe 'before validation' do
    describe 'format ni_number' do
      subject { applicant.ni_number }

      let(:expected_ni_number) { 'JN010203A' }
      let(:applicant) { build :applicant, application: application, ni_number: ni_number }

      before do
        applicant.valid?
      end

      context 'with lower case letters' do
        let(:ni_number) { 'jn 01 02 03 a' }

        it 'converts the letters to upper case' do
          is_expected.to eql(expected_ni_number)
        end
      end

      context 'with spaces' do
        let(:ni_number) { 'JN 01 02 03 A' }

        it 'is stripped of all spaces before stored' do
          is_expected.to eql(expected_ni_number)
        end
      end

      context 'without spaces' do
        let(:ni_number) { expected_ni_number }

        it 'is stored as inputted' do
          is_expected.to eql(expected_ni_number)
        end
      end

      context 'when nil' do
        let(:ni_number) { nil }

        it { is_expected.to be nil }
      end
    end
  end

  describe 'validation' do
    subject { applicant.valid? }

    let(:expected_ni_number) { 'JN010203A' }
    let(:applicant) { build :applicant, application: application, ni_number: ni_number }

    describe 'of ni_number' do
      context 'when nil' do
        let(:ni_number) { nil }

        it { is_expected.to be true }
      end

      context 'with invalid format' do
        let(:ni_number) { 'asdasdf' }

        it { is_expected.to be false }
      end

      context 'with valid format' do
        let(:ni_number) { 'AB121212C' }

        it { is_expected.to be true }
      end
    end
  end

  describe '#age' do
    subject { applicant.age }

    context 'when applicant is earlier in the year' do
      before { applicant.date_of_birth = (Time.zone.now - 3.months) - 17.years }

      it 'returns the correct value' do
        is_expected.to eq 17
      end
    end

    context 'when applicants birthday is later in the year' do
      before { applicant.date_of_birth = (Time.zone.now + 3.months) - 17.years }

      it 'returns the correct value' do
        is_expected.to eq 16
      end
    end

    context 'when applicant is born on Feb 29th in a leap year' do
      before { applicant.date_of_birth = Date.new(1964, 2, 29) }

      it 'returns the correct value' do
        Timecop.freeze(Date.new(2014, 10, 28)) do
          is_expected.to eq 50
        end
      end
    end
  end

  describe '#full_name' do
    subject { applicant.full_name }

    context 'when title, first_name and last_name are set' do
      let(:applicant) { build :applicant, application: application, title: 't', first_name: 'f', last_name: 'l' }

      it 'returns all parts with spaces between' do
        is_expected.to eql('t f l')
      end
    end

    context 'when only some of the name fields are set' do
      let(:applicant) { build :applicant, application: application, title: 't', first_name: nil, last_name: 'l' }

      it 'returns all only the set parts with spaces between' do
        is_expected.to eql('t l')
      end
    end

    context 'when non of the name fields are set' do
      let(:applicant) { build :applicant, application: application, title: nil, first_name: nil, last_name: nil }

      it 'returns an empty string' do
        is_expected.to eql('')
      end
    end
  end

  describe '#over_61?' do
    subject do
      Timecop.freeze(current_time) do
        applicant.over_61?
      end
    end

    let(:current_time) { Time.zone.parse('2016-03-04') }
    let(:dob_over) { Time.zone.parse('1955-03-01') }
    let(:dob_under) { Time.zone.parse('1965-03-01') }
    let(:applicant) { build :applicant, application: application, date_of_birth: date_of_birth }

    context 'when the applicant is over 61 years old' do
      let(:date_of_birth) { dob_over }

      it { is_expected.to be true }
    end

    context 'when the applicant is not over 61 years old' do
      let(:date_of_birth) { dob_under }

      it { is_expected.to be false }
    end
  end
end
