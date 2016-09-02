require 'rails_helper'

RSpec.describe Views::Overview::Applicant do

  let(:application) { build_stubbed(:application) }
  subject(:view) { described_class.new(application) }

  describe '#all_fields' do
    subject { view.all_fields }

    it { is_expected.to eql(%w[full_name date_of_birth ni_number status]) }
  end

  describe '#ni_number' do
    it { expect(view.ni_number).to eql application.applicant.ni_number }
  end

  describe '#status' do
    subject { view.status }

    context 'when the applicant is married' do
      let(:application) { build_stubbed(:married_applicant_over_61) }

      it { is_expected.to eql 'Married or living with someone and sharing an income' }
    end

    context 'when the applicant is single' do
      let(:application) { build_stubbed(:single_applicant_over_61) }

      it { is_expected.to eql 'Single' }
    end
  end

  describe '#date_of_birth' do
    let(:applicant) { build_stubbed(:applicant, date_of_birth: Time.zone.parse('1990-11-20')) }
    let(:application) { build_stubbed(:application, applicant: applicant) }

    it 'formats the date correctly' do
      expect(view.date_of_birth).to eql('20 November 1990')
    end
  end

  describe 'delegated methods' do
    describe '-> Applicant' do
      %i[full_name].each do |getter|
        it { expect(subject.public_send(getter)).to eql(application.applicant.public_send(getter)) }
      end
    end
  end
end
