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
end
