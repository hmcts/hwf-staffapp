# coding: utf-8
require 'rails_helper'

RSpec.describe Views::ProcessingDetails do
  let(:application) { build_stubbed(:application) }
  let(:record) { double(application: application) }

  subject(:view) { described_class.new(record) }

  it { is_expected.to delegate_method(:reference).to(:application) }

  describe '#expires' do
    let(:record) { double(application: application, expires_at: expiration_date) }

    subject { view.expires }

    context 'when the evidence check expires in a few days' do
      let(:expiration_date) { Time.zone.now + 3.days }

      it { is_expected.to eq '3 days' }
    end

    context 'when the evidence check expires today' do
      let(:expiration_date) { Time.zone.now }

      it { is_expected.to eq 'expired' }
    end

    context 'when the evidence check has expired' do
      let(:expiration_date) { Time.zone.yesterday }

      it { is_expected.to eq 'expired' }
    end
  end

  describe '#processed_by' do
    subject { view.processed_by }

    it 'returns the name of the user who created the application' do
      is_expected.to eql(application.user.name)
    end
  end

  describe '#applicant' do
    subject { view.applicant }

    it 'returns the full name of the applicant' do
      is_expected.to eql(application.full_name)
    end
  end
end
