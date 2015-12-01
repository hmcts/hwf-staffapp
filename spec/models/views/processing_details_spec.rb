# coding: utf-8
require 'rails_helper'

RSpec.describe Views::ProcessingDetails do
  let(:completed_at) { '2015-11-01' }
  let(:application) { build_stubbed(:application, completed_at: completed_at) }
  let(:record) { double(application: application) }

  subject(:view) { described_class.new(record) }

  it { is_expected.to delegate_method(:reference).to(:application) }

  describe '#expires' do
    let(:expires_at) { 2.days.from_now }
    let(:record) { double(application: application, expires_at: expires_at) }

    subject { view.expires }

    it 'returns just date' do
      is_expected.to be_a(Date)
    end

    it 'returns the correct date from the record\'s expires_at' do
      is_expected.to eq(expires_at.to_date)
    end
  end

  describe '#processed_by' do
    subject { view.processed_by }

    it 'returns the name of the user who completed the application' do
      is_expected.to eql(application.completed_by.name)
    end

    describe 'when completed_by is missing' do
      before { application.completed_by = nil }

      it { is_expected.to be_nil }
    end
  end

  describe '#processed_on' do
    subject { view.processed_on }

    context 'when completed_at is missing' do
      let(:completed_at) { nil }

      it { is_expected.to be nil }
    end

    context 'when completed_at is set' do
      it 'returns the date the application was completed' do
        is_expected.to eql('1 November 2015')
      end
    end
  end

  describe '#applicant' do
    subject { view.applicant }

    it 'returns the full name of the applicant' do
      is_expected.to eql(application.full_name)
    end
  end
end
