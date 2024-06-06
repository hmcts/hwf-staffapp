# coding: utf-8

require 'rails_helper'

describe OnlineApplicationBuilder do

  let(:current_time) { Time.zone.now }
  let(:submission) { { 'benefits' => 'false' } }

  describe '#build' do
    subject(:build_submission) { described_class.new(submission).build }

    it 'returns non persisted OnlineApplication' do
      is_expected.to be_a(OnlineApplication)
      is_expected.not_to be_persisted
    end

    describe 'it adds a reference number' do
      subject(:reference) { build_submission.reference }

      it { is_expected.not_to be_nil }
      it { is_expected.to include('HWF-A') }
    end

    describe 'it adds a reference number for benefits' do
      let(:submission) { { 'benefits' => 'true' } }
      subject(:reference) { build_submission.reference }

      it { is_expected.not_to be_nil }
      it { is_expected.to include('HWF-Z') }
    end
  end
end
