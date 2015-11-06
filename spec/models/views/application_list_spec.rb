require 'rails_helper'

RSpec.describe Views::ApplicationList do
  let(:applicant) { build(:applicant) }
  let(:detail) { build(:detail, date_received: '2015-10-01') }
  let(:application) { build(:application, applicant: applicant, detail: detail) }

  subject(:view) { described_class.new(application) }

  describe '#applicant' do
    it 'returns the applicant\'s full name' do
      expect(view.applicant).to eql(applicant.full_name)
    end
  end

  describe '#date_received' do
    it 'returns formatted date of application received date' do
      expect(view.date_received).to eql('1 October 2015')
    end
  end

  describe '#processed_by' do
    it 'returns the name of the user who created the application' do
      expect(view.processed_by).to eql(application.user.name)
    end
  end

  describe '#emergency' do
    let(:detail) { build(:detail, emergency_reason: emergency_reason) }

    subject { view.emergency }

    context 'when emergency reason is empty' do
      let(:emergency_reason) { nil }

      it 'returns empty string' do
        is_expected.to eql ''
      end
    end

    context 'when emergency reason is set' do
      let(:emergency_reason) { 'some reason' }

      it 'returns Yes' do
        is_expected.to eql 'Yes'
      end
    end
  end
end
