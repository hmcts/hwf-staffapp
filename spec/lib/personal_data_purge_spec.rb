require 'rails_helper'

RSpec.describe PersonalDataPurge do
  subject(:purge_object) { described_class.new([application1]) }
  describe 'settings for data range' do
    it { expect(Settings.personal_data_purge.years_ago).to be(7) }
  end
  let(:benefit_check1) { build(:benefit_check, parameter_hash: 'personal_data1', our_api_token: 'includes data too1') }
  let(:benefit_check2) { build(:benefit_check, parameter_hash: 'personal_data2', our_api_token: 'includes data too2') }
  let(:online_benefit_check1) { build(:benefit_check, parameter_hash: 'personal_data1', our_api_token: 'includes data too1') }
  let(:online_benefit_check2) { build(:benefit_check, parameter_hash: 'personal_data2', our_api_token: 'includes data too2') }

  describe 'purge online_application only' do
    subject(:purge_object) { described_class.new([online_application]) }
    let(:online_application) { create(:online_application_with_all_details, benefit_checks: [online_benefit_check1, online_benefit_check2]) }
    before {
      purge_object.purge_online_only!
    }

    it { expect(online_application.reload.purged).to be true }

    context 'benefit_checks' do
      let(:keys) { [:parameter_hash, :our_api_token, :last_name, :ni_number] }
      it {
        online_benefit_check1.reload
        values = keys.map { |key| online_benefit_check1[key] }
        expect(values).to eq [nil, nil, nil, nil]
      }

      it {
        online_benefit_check2.reload
        values = keys.map { |key| online_benefit_check2[key] }
        expect(values).to eq [nil, nil, nil, nil]
      }
    end
  end

  describe 'purge data' do
    subject(:purge) { purge_object.purge! }
    # rubocop:disable Lint/EmptyBlock
    let(:hmrc_checks) {}
    # rubocop:enable Lint/EmptyBlock
    let(:application1) {
      create(:application, applicant_traits: [:ho_number],
                           benefit_checks: [benefit_check1, benefit_check2], detail_traits: [:probate], online_application: online_application,
                           completed_at: 8.years.ago)
    }
    let(:online_application) { create(:online_application_with_all_details, benefit_checks: [online_benefit_check1, online_benefit_check2]) }
    let(:audit_data) { AuditPersonalDataPurge.last }

    before {
      hmrc_checks
      purge
    }
    it { expect(application1.reload.purged).to be true }
    it { expect(application1.reload.purged_at.to_fs(:db)).to eq Time.zone.today.to_fs(:db) }
    it { expect(online_application.reload.purged).to be true }
    it { expect(online_application.reload.purged_at.to_fs(:db)).to eq Time.zone.today.to_fs(:db) }
    it { expect(audit_data.purged_date.to_fs(:db)).to eq Time.zone.today.to_fs(:db) }
    it { expect(audit_data.application_reference_number).to eq application1.reference }

    context 'applicant' do
      let(:applicant) { application1.applicant }
      let(:keys) { [:title, :first_name, :last_name, :ni_number, :ho_number] }
      it {
        applicant.reload
        values = keys.map { |key| applicant[key] }
        expect(values).to eq [nil, nil, nil, nil, nil]
      }
    end

    context 'benefit_checks' do
      let(:keys) { [:parameter_hash, :our_api_token, :last_name, :ni_number] }
      it {
        benefit_check1.reload
        values = keys.map { |key| benefit_check1[key] }
        expect(values).to eq [nil, nil, nil, nil]
      }

      it {
        benefit_check2.reload
        values = keys.map { |key| benefit_check2[key] }
        expect(values).to eq [nil, nil, nil, nil]
      }
    end

    context 'online benefit_checks' do
      let(:keys) { [:parameter_hash, :our_api_token, :last_name, :ni_number] }
      it {
        online_benefit_check1.reload
        values = keys.map { |key| online_benefit_check1[key] }
        expect(values).to eq [nil, nil, nil, nil]
      }

      it {
        online_benefit_check2.reload
        values = keys.map { |key| online_benefit_check2[key] }
        expect(values).to eq [nil, nil, nil, nil]
      }
    end

    context 'detail' do
      let(:detail) { application1.detail }
      let(:keys) { [:deceased_name, :date_of_death, :case_number] }
      it {
        detail.reload
        values = keys.map { |key| detail[key] }
        expect(values).to eq [nil, nil, nil]
      }
    end

    context 'online_application' do
      let(:keys) {
        [:deceased_name, :date_of_death, :case_number,
         :title, :first_name, :last_name, :ni_number, :ho_number,
         :address, :email_address, :phone]
      }
      let(:expected_values) {
        ['data purged', nil, 'data purged', 'data purged', 'data purged', 'data purged',
         'data purged', 'data purged', 'data purged', 'data purged', 'data purged']
      }
      it {
        online_application.reload
        values = keys.map { |key| online_application[key] }
        expect(values).to eq expected_values
      }
    end

    context 'hmrc_check' do
      let(:hmrc_check1) { create(:hmrc_check, evidence_check: application1.evidence_check) }
      let(:hmrc_check2) { create(:hmrc_check, evidence_check: application1.evidence_check) }
      let(:evidence_check) { application1.evidence_check }
      let(:application1) {
        create(:application, :waiting_for_evidence_state, completed_at: 8.years.ago)
      }
      let(:user) { create(:user) }
      let(:keys) { [:address, :ni_number] }
      let(:hmrc_checks) {
        hmrc_check1
        hmrc_check2
      }

      it {
        hmrc_check1.reload
        values = keys.map { |key| hmrc_check1[key] }
        expect(values).to eq [nil, nil]
      }

      it {
        hmrc_check2.reload
        values = keys.map { |key| hmrc_check2[key] }
        expect(values).to eq [nil, nil]
      }
    end

  end

end
