# coding: utf-8
require 'rails_helper'

RSpec.describe Views::Reports::PublicSubmissionData do

  subject(:data) { described_class.new }

  describe '#submission_all_time_total' do
    subject { data.submission_all_time_total }

    it { is_expected.to be_a Integer }
  end

  describe '#submission_all_time' do
    subject { data.submission_all_time }

    it { is_expected.to be_a Hash }
  end

  describe '#submission_seven_day_total' do
    subject { data.submission_seven_day_total }

    it { is_expected.to be_a Integer }
  end

  describe '#submission_seven_day' do
    subject { data.submission_seven_day }

    it { is_expected.to be_a Hash }
  end

  describe '#submission_total_time_taken' do
    subject { data.submission_total_time_taken }

    it { is_expected.to be_a Array }
  end

  describe '#submission_seven_day_time_taken' do
    subject { data.submission_seven_day_time_taken }

    it { is_expected.to be_a Array }
  end

  describe 'when populated with data' do
    let(:user) { create :staff }

    before do
      Timecop.freeze(8.days.ago) do
        create_list :online_application, 8, :completed, :with_reference, convert_to_application: true
      end
      Timecop.freeze(2.days.ago) do
        create_list :online_application, 2, :completed, :with_reference, convert_to_application: true
      end
    end

    it 'returns expected values' do
      expect(data.submission_all_time_total).to eq 10
      expect(data.submission_seven_day_total).to eq 2
      expect(data.submission_all_time.count).to eq 10
      expect(data.submission_seven_day.count).to eq 2
      expect(data.submission_total_time_taken.count).to eq 10
      expect(data.submission_seven_day_time_taken.count).to eq 2
    end
  end
end
