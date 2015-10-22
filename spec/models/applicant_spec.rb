require 'rails_helper'

RSpec.describe Applicant, type: :model do
  let(:application) { build_stubbed(:application) }

  it { is_expected.to belong_to(:application) }
  it { is_expected.to validate_presence_of(:application) }

  describe 'before validation' do
    describe 'format ni_number' do
      let(:expected_ni_number) { 'JN010203A' }
      let(:applicant) { build :applicant, application: application, ni_number: ni_number }

      before do
        applicant.valid?
      end

      subject { applicant.ni_number }

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
    let(:expected_ni_number) { 'JN010203A' }
    let(:applicant) { build :applicant, application: application, ni_number: ni_number }

    subject { applicant.valid? }

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
end
