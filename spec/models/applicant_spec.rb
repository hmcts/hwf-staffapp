require 'rails_helper'

RSpec.describe Applicant do
  let(:application) { build_stubbed(:application, date_received: date_received) }
  let(:applicant) { build(:applicant, application: application) }
  let(:date_received) { Time.zone.today }

  it { is_expected.to validate_presence_of(:application) }

  describe 'before validation' do
    describe 'format ni_number' do
      subject { applicant.ni_number }

      let(:expected_ni_number) { 'JN010203A' }
      let(:applicant) { build(:applicant, application: application, ni_number: ni_number) }

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

        it { is_expected.to be_nil }
      end
    end
  end

  describe 'validation' do
    subject { applicant.valid? }

    let(:expected_ni_number) { 'JN010203A' }
    let(:applicant) { build(:applicant, application: application, ni_number: ni_number) }

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

  context 'HO number' do
    let(:ho_number) { 'l1234567' }
    let(:applicant) { build(:applicant, application: application, ho_number: ho_number) }

    it { expect(applicant.valid?).to be true }

    it 'capitalize ho number before save' do
      applicant.valid?
      expect(applicant.ho_number).to eq('L1234567')
    end
  end

  describe '#age' do
    subject { applicant.age }

    context 'when applicant is earlier in the year' do
      before { applicant.date_of_birth = 3.months.ago - 17.years }

      it 'returns the correct value' do
        is_expected.to eq 17
      end
    end

    context 'when applicants birthday is later in the year' do
      before { applicant.date_of_birth = 3.months.from_now - 17.years }

      it 'returns the correct value' do
        is_expected.to eq 16
      end
    end

    context 'when applicant is born on Feb 29th in a leap year' do
      before { applicant.date_of_birth = Date.new(1964, 2, 29) }

      it 'returns the correct value' do
        travel_to(Date.new(2014, 10, 28)) do
          is_expected.to eq 50
        end
      end
    end
  end

  describe '#full_name' do
    subject { applicant.full_name }

    context 'when title, first_name and last_name are set' do
      let(:applicant) { build(:applicant, application: application, title: 't', first_name: 'f', last_name: 'l') }

      it 'returns all parts with spaces between' do
        is_expected.to eql('t f l')
      end
    end

    context 'when only some of the name fields are set' do
      let(:applicant) { build(:applicant, application: application, title: 't', first_name: nil, last_name: 'l') }

      it 'returns all only the set parts with spaces between' do
        is_expected.to eql('t l')
      end
    end

    context 'when non of the name fields are set' do
      let(:applicant) { build(:applicant, application: application, title: nil, first_name: nil, last_name: nil) }

      it 'returns an empty string' do
        is_expected.to eql('')
      end
    end
  end

  describe '#over_66?' do
    subject do
      travel_to(current_time) do
        applicant.over_66?
      end
    end

    let(:current_time) { Time.zone.parse('2016-03-04') }
    let(:dob_over) { Time.zone.parse('1940-03-01') }
    let(:dob_under) { Time.zone.parse('1965-03-01') }
    let(:applicant) { build(:applicant, application: application, date_of_birth: date_of_birth) }

    context 'when The applicant is over 66 years old' do
      let(:date_of_birth) { dob_over }

      it { is_expected.to be true }

      context 'but the application was received when he was not yet over' do
        let(:date_received) { dob_over + 60.years }
        it { is_expected.to be false }
      end
    end

    context 'when the applicant is not over 66 years old' do
      let(:date_of_birth) { dob_under }

      it { is_expected.to be false }
    end
  end

  describe '#under_age?' do
    subject do
      travel_to(current_time) do
        applicant.under_age?
      end
    end

    let(:current_time) { Time.zone.parse('2020-09-11') }
    let(:dob_over) { Time.zone.parse('2004-9-10') }
    let(:dob_under) { Time.zone.parse('2005-09-12') }
    let(:applicant) { build(:applicant, application: application, date_of_birth: date_of_birth) }

    context 'when the applicant is over 15 years old' do
      let(:date_of_birth) { dob_over }

      it { is_expected.to be false }
    end

    context 'when the applicant is not over 15 years old' do
      let(:date_of_birth) { dob_under }

      it { is_expected.to be true }
    end

    context 'when the applicant is exactly 16 years old' do
      let(:date_of_birth) { Time.zone.parse('2004-09-11') }

      it { is_expected.to be false }
    end
  end

  describe 'remove partner info' do
    let(:application) { build(:application, date_received: date_received) }
    let(:applicant) { build(:applicant, application: application) }

    it 'only when change from married to single' do
      applicant = create(:applicant, application: application, married: true,
                                     partner_date_of_birth: Time.zone.today,
                                     partner_first_name: 'Jim',
                                     partner_last_name: 'Jones',
                                     partner_ni_number: 'sn798466c')

      applicant.update(married: false)
      expect(applicant.partner_date_of_birth).to be_nil
      expect(applicant.partner_first_name).to be_nil
      expect(applicant.partner_last_name).to be_nil
      expect(applicant.partner_ni_number).to be_nil
    end
  end
end
