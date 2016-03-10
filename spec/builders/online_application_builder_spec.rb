# coding: utf-8
require 'rails_helper'

describe OnlineApplicationBuilder do

  let(:current_time) { Time.zone.now }
  let(:submission) { attributes_for :public_app_submission }

  describe '#build' do
    subject(:build_submission) { described_class.new(submission).build }

    it 'returns non persisted OnlineApplication' do
      is_expected.to be_a(OnlineApplication)
      is_expected.not_to be_persisted
    end

    describe 'email contact' do
      subject(:email) { build_submission.email_address }
      describe 'when applicant responds `no`' do
        it { is_expected.to eql nil }
      end

      describe 'when applicant responds `no`' do
        let(:submission) { attributes_for :public_app_submission, :email_contact }

        it { is_expected.to eql 'foo@bar.com' }
      end
    end

    describe 'children field' do
      subject(:children) { build_submission.children }
      describe 'when applicant responds `no`' do
        it { is_expected.to eql 0 }
      end

      describe 'when applicant responds `yes`' do
        let(:submission) { attributes_for :public_app_submission, :with_children }

        it { is_expected.to eql 1 }
      end
    end
  end
end
