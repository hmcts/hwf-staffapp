require 'rails_helper'

RSpec.describe Views::ApplicationList do
  let(:user) { build :user }
  let(:applicant) { build(:applicant) }
  let(:detail) { build(:detail, date_received: '2015-10-01') }
  let(:completed_by) { user }
  let(:completed_at) { Date.new(2015, 10, 02) }
  let(:application) do
    build(:application, applicant: applicant, detail: detail, completed_by: completed_by, completed_at: completed_at)
  end

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
    subject { view.processed_by }

    context 'when completed_by is set' do
      it 'returns the name of the user who completed the application' do
        is_expected.to eql(application.completed_by.name)
      end
    end

    context 'when completed_by is nil' do
      let(:completed_by) { nil }

      it 'returns nil' do
        is_expected.to be nil
      end
    end
  end

  describe '#processed_on' do
    subject { view.processed_on }

    context 'when processed_on is set' do
      it 'returns the date the application was completed' do
        is_expected.to eql('2 October 2015')
      end
    end

    context 'when processed_on is nil' do
      let(:completed_at) { nil }

      it 'returns nil' do
        is_expected.to be nil
      end
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
