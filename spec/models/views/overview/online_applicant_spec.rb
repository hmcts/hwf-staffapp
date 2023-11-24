require 'rails_helper'

RSpec.describe Views::Overview::OnlineApplicant do
  subject(:view) { described_class.new(application) }

  let(:application) {
    build_stubbed(:online_application,
                  married: married, date_of_birth: date_of_birth, over_16: over_16, partner_first_name: partner_first_name,
                  partner_date_of_birth: partner_date_of_birth)
  }

  let(:married) { false }
  let(:date_of_birth) { Time.zone.parse('1990-11-20') }
  let(:over_16) { true }
  let(:partner_date_of_birth) { Time.zone.parse('1980-11-20') }
  let(:partner_first_name) { 'John' }

  describe '#all_fields' do
    subject { view.all_fields }

    it {
      is_expected.to eql(['full_name', 'date_of_birth', 'under_age', 'ni_number', 'ho_number', 'status',
                          'partner_full_name', 'partner_date_of_birth', 'partner_ni_number'])
    }
  end

  describe '#ni_number' do
    it { expect(view.ni_number.delete(' ')).to eql application.applicant.ni_number }
  end

  describe '#ho_number' do
    it { expect(view.ho_number).to eql application.applicant.ho_number }
  end

  describe '#status' do
    subject { view.status }

    context 'when the applicant is married' do
      let(:married) { true }

      it { is_expected.to eql 'Married or living with someone and sharing an income' }
    end

    context 'when the applicant is single' do
      let(:married) { false }

      it { is_expected.to eql 'Single' }
    end
  end

  describe '#date_of_birth' do
    it 'formats the date correctly' do
      expect(view.date_of_birth).to eql('20 November 1990')
    end
  end

  describe '#partner_date_of_birth' do
    it 'formats the date correctly' do
      expect(view.partner_date_of_birth).to eql('20 November 1980')
    end
  end

  describe '#partner_date_of_birth when first name is nil' do
    let(:partner_first_name) { nil }
    it 'formats the date correctly' do
      expect(view.partner_date_of_birth).to be_nil
    end
  end

  describe '#under_age' do
    context 'under 16' do
      let(:over_16) { false }
      it 'returns state correctly' do
        expect(view.under_age).to eql 'Yes'
      end
    end

    context 'over 16' do
      let(:over_16) { nil }
      it 'returns state correctly' do
        expect(view.under_age).to be_nil
      end
    end

    context 'online application' do
      context 'under 16' do
        let(:dob) { 15.years.ago }
        it 'returns state correctly' do
          expect(view.under_age).to eql 'Yes'
        end
      end
    end
  end
end
