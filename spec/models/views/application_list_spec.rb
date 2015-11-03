require 'rails_helper'

RSpec.describe Views::ApplicationList do
  let(:applicant) { build(:applicant) }
  let(:detail) { build(:detail) }
  let(:application) { build(:application, applicant: applicant, detail: detail) }

  subject(:view) { described_class.new(application) }

  it { is_expected.to delegate_method(:reference).to(:application) }

  describe '#applicant' do
    it 'returns the applicant\'s full name' do
      expect(view.applicant).to eql(applicant.full_name)
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
