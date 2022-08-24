require 'rails_helper'

RSpec.describe PersonalDataPurge do
  subject(:purge_object) { described_class.new }
  describe 'settings for data range' do
    it { expect(Settings.personal_data_purge.years_ago).to be(7) }
  end
  let(:benefit_check1) { build :benefit_check, parameter_hash: 'personal_data1', our_api_token: 'includes data too1' }
  let(:benefit_check2) { build :benefit_check, parameter_hash: 'personal_data2', our_api_token: 'includes data too2' }
  let(:online_benefit_check1) { build :online_benefit_check, parameter_hash: 'personal_data1', our_api_token: 'includes data too1' }
  let(:online_benefit_check2) { build :online_benefit_check, parameter_hash: 'personal_data2', our_api_token: 'includes data too2' }

  describe 'load data' do

    let(:application1) { create :application }
    let(:application2) { create :application }
    before do
      Timecop.freeze(7.years.ago) do
        application1
      end
      application2
    end

    it { expect(purge_object.applications_to_purge.count).to be(1) }
    it { expect(purge_object.applications_to_purge.first.id).to eql(application1.id) }

  end

  describe 'purge data' do
    let(:application1) { create :application, applicant_traits: [:ho_number],
      benefit_checks: [benefit_check1, benefit_check2], detail_traits: [:probate], online_application: online_application,
      completed_at: 8.years.ago }
    let(:online_application) { create :online_application_with_all_details, online_benefit_checks: [online_benefit_check1, online_benefit_check2] }

    subject(:purge) { purge_object.purge! }
    before {
      application1
      purge
    }

    context 'applicant' do
      let(:applicant) { application1.applicant }
      it { expect(applicant.reload.title).to be_nil }
      it { expect(applicant.reload.first_name).to be_nil }
      it { expect(applicant.reload.last_name).to be_nil }
      it { expect(applicant.reload.ni_number).to be_nil }
      it { expect(applicant.reload.ho_number).to be_nil }
    end

    context 'benefit_checks' do
      it { expect(benefit_check1.reload.parameter_hash).to be_nil }
      it { expect(benefit_check1.reload.our_api_token).to be_nil }
      it { expect(benefit_check1.reload.last_name).to be_nil }
      it { expect(benefit_check1.reload.ni_number).to be_nil }
      it { expect(benefit_check2.reload.parameter_hash).to be_nil }
      it { expect(benefit_check2.reload.our_api_token).to be_nil }
      it { expect(benefit_check2.reload.last_name).to be_nil }
      it { expect(benefit_check2.reload.ni_number).to be_nil }
    end

    context 'online_benefit_checks' do
      it { expect(online_benefit_check1.reload.parameter_hash).to be_nil }
      it { expect(online_benefit_check1.reload.our_api_token).to be_nil }
      it { expect(online_benefit_check1.reload.last_name).to be_nil }
      it { expect(online_benefit_check1.reload.ni_number).to be_nil }
      it { expect(online_benefit_check2.reload.parameter_hash).to be_nil }
      it { expect(online_benefit_check2.reload.our_api_token).to be_nil }
      it { expect(online_benefit_check2.reload.last_name).to be_nil }
      it { expect(online_benefit_check2.reload.ni_number).to be_nil }
    end

    context 'detail' do
      let(:detail) { application1.detail }
      it { expect(detail.reload.deceased_name).to be_nil }
      it { expect(detail.reload.date_of_death).to be_nil }
      it { expect(detail.reload.case_number).to be_nil }
    end

    context 'online_application' do
      it { expect(online_application.reload.deceased_name).to eq 'data purged' }
      it { expect(online_application.reload.date_of_death).to be_nil }
      it { expect(online_application.reload.case_number).to eq 'data purged' }
      it { expect(online_application.reload.title).to eq 'data purged' }
      it { expect(online_application.reload.first_name).to eq 'data purged' }
      it { expect(online_application.reload.last_name).to eq 'data purged' }
      it { expect(online_application.reload.ni_number).to eq 'data purged' }
      it { expect(online_application.reload.ho_number).to eq 'data purged' }
      it { expect(online_application.reload.address).to eq 'data purged' }
      it { expect(online_application.reload.email_address).to eq 'data purged' }
      it { expect(online_application.reload.phone).to eq 'data purged' }
    end
    it { expect(application1.evidence_check).to be_nil }

    context 'hmrc_check' do
      let(:hmrc_check1) { create :hmrc_check }
      let(:hmrc_check2) { create :hmrc_check }
      let(:evidence_check) { create :evidence_check, hmrc_checks: [hmrc_check1, hmrc_check2] }
      let(:application1) { create :application, evidence_check: evidence_check, completed_at: 8.years.ago }

      it { expect(hmrc_check1.reload.address).to be_nil }
      it { expect(hmrc_check1.reload.ni_number).to be_nil }
      it { expect(hmrc_check2.reload.address).to be_nil }
      it { expect(hmrc_check2.reload.ni_number).to be_nil }
    end

  end

end
