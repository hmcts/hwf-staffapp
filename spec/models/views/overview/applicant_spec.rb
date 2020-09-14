require 'rails_helper'

RSpec.describe Views::Overview::Applicant do
  subject(:view) { described_class.new(application) }

  let(:application) { build_stubbed(:application) }

  describe '#all_fields' do
    subject { view.all_fields }

    it { is_expected.to eql(['full_name', 'date_of_birth', 'under_age', 'ni_number', 'ho_number', 'status']) }
  end

  describe '#ni_number' do
    it { expect(view.ni_number).to eql application.applicant.ni_number }
  end

  describe '#ho_number' do
    it { expect(view.ho_number).to eql application.applicant.ho_number }
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

  describe '#under_age' do
    let(:application) { build_stubbed(:application, applicant: applicant) }
    context 'under 16' do
      let(:applicant) { build_stubbed(:applicant, date_of_birth: 15.years.ago) }
      it 'returns state correctly' do
        expect(view.under_age).to eql 'Yes'
      end
    end

    context 'over 16' do
      let(:applicant) { build_stubbed(:applicant, date_of_birth: 17.years.ago) }
      it 'returns state correctly' do
        expect(view.under_age).to be_nil
      end
    end

    context 'online application' do
      let(:application) { build_stubbed(:online_application, date_of_birth: dob) }

      context 'under 16' do
        let(:dob) { 15.years.ago }
        it 'returns state correctly' do
          expect(view.under_age).to eql 'Yes'
        end
      end
    end
  end

  describe 'delegated methods' do
    describe '-> Applicant' do
      [:full_name].each do |getter|
        it { expect(view.public_send(getter)).to eql(application.applicant.public_send(getter)) }
      end
    end
  end
end
