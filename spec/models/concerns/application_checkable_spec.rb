require 'rails_helper'

describe ApplicationCheckable do
  subject(:application) { application }

  describe 'skipp EV check?' do
    let(:application) { build(:application, outcome: outcome, application_type: application_type, detail: detail, applicant: applicant) }
    let(:detail) { build(:detail, emergency_reason: emergency_reason, discretion_applied: discretion_applied) }
    let(:applicant) { build(:applicant_with_all_details, date_of_birth: dob) }
    let(:emergency_reason) { nil }
    let(:discretion_applied) { nil }
    let(:outcome) { 'full' }
    let(:application_type) { 'income' }
    let(:dob) { 30.years.ago }

    context 'if it is emergency' do
      let(:emergency_reason) { 'emergency' }

      it { expect(application.skip_ev_check?).to be true }
    end

    context 'not emergency' do
      let(:emergency_reason) { nil }

      it { expect(application.skip_ev_check?).to be false }
    end

    context 'outcome' do
      describe 'none' do
        let(:outcome) { 'none' }
        it { expect(application.skip_ev_check?).to be true }
      end

      describe 'part' do
        let(:outcome) { 'part' }
        it { expect(application.skip_ev_check?).to be false }
      end

      describe 'full' do
        let(:outcome) { 'full' }
        it { expect(application.skip_ev_check?).to be false }
      end

      describe 'nil' do
        let(:outcome) { nil }
        it { expect(application.skip_ev_check?).to be false }
      end
    end

    context 'application_type' do
      describe 'income' do
        let(:application_type) { 'income' }
        it { expect(application.skip_ev_check?).to be false }
      end

      describe 'benefit' do
        let(:application_type) { 'benefit' }
        it { expect(application.skip_ev_check?).to be true }
      end

      describe 'blank' do
        let(:application_type) { 'none' }
        it { expect(application.skip_ev_check?).to be true }
      end
    end

    context 'under age?' do
      describe '15 years' do
        let(:dob) { 15.years.ago }
        it { expect(application.skip_ev_check?).to be true }
      end

      describe '16 years' do
        let(:dob) { 16.years.ago }
        it { expect(application.skip_ev_check?).to be false }
      end
    end

    context 'discretion_applied?' do
      describe 'yes' do
        let(:discretion_applied) { true }
        it { expect(application.skip_ev_check?).to be false }
      end

      describe 'no' do
        let(:discretion_applied) { false }
        it { expect(application.skip_ev_check?).to be true }
      end

      describe 'blank' do
        let(:discretion_applied) { nil }
        it { expect(application.skip_ev_check?).to be false }
      end
    end
  end

  context 'HMRC check applies' do
    let(:application) { build(:application, income_kind: income_kind, applicant: applicant, office: office, medium: medium) }
    let(:income_kind) { { "applicant" => ["Wages"] } }
    let(:applicant) { build(:applicant, married: married) }
    let(:married) { false }
    let(:office) { create(:office, entity_code: 'dig') }
    let(:medium) { 'digital' }

    before do
      Settings.evidence_check.hmrc.office_entity_code = ['dig']
    end

    context 'single applicant' do
      let(:married) { false }
      it { expect(application.hmrc_check_type?).to be true }
    end

    context 'married applicant' do
      let(:married) { true }
      it { expect(application.hmrc_check_type?).to be false }
    end

    context 'digital application' do
      let(:medium) { 'digital' }
      it { expect(application.hmrc_check_type?).to be true }
    end

    context 'paper application' do
      let(:medium) { 'paper' }
      it { expect(application.hmrc_check_type?).to be false }
    end

    context 'tax credit declared' do
      describe 'wages' do
        let(:income_kind) { { "applicant" => ["Wages"] } }
        it { expect(application.hmrc_check_type?).to be true }
      end

      describe 'income kind empty hash' do
        let(:income_kind) { {} }
        it { expect(application.hmrc_check_type?).to be true }
      end

      describe 'income kind empty value' do
        let(:income_kind) { { "applicant" => nil } }
        it { expect(application.hmrc_check_type?).to be true }
      end
    end

    context 'office does not match' do
      let(:office) { create(:office, entity_code: 'dig01') }
      it { expect(application.hmrc_check_type?).to be false }
    end

    context 'office does match' do
      let(:office) { create(:office, entity_code: 'dig') }
      it { expect(application.hmrc_check_type?).to be true }
    end
  end

end
