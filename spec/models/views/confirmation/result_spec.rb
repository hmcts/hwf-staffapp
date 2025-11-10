# coding: utf-8

require 'rails_helper'

RSpec.describe Views::Confirmation::Result do
  subject(:view) { described_class.new(application) }

  let(:application) { build_stubbed(:application, detail: detail) }
  let(:string_passed) { '✓ Passed' }
  let(:string_failed) { '✗ Failed' }
  let(:string_waiting_evidence) { 'Waiting for evidence' }
  let(:string_part_payment) { 'Waiting for part-payment' }
  let(:scope) { 'convert_pass_fail' }
  let(:saving) { double }
  let(:detail) { build_stubbed(:detail) }

  describe '#all_fields' do
    subject { view.all_fields }
    context 'band calculation not active' do
      it { is_expected.to eql ['discretion_applied?', 'savings_passed?', 'benefits_passed?', 'income_passed?'] }
    end

    context 'band calculation active' do
      before { allow(FeatureSwitching).to receive(:active?).with(:band_calculation).and_return true }
      it { is_expected.to eql ['discretion_applied?', 'savings_passed?', 'benefits_passed?', 'income_passed?', 'calculation_scheme'] }
    end

  end

  describe '#discretion_applied?' do
    subject { view.discretion_applied? }

    context "when discretion is denied" do
      let(:detail) { build_stubbed(:detail, discretion_applied: false) }

      it { is_expected.to eq I18n.t(false.to_s, scope: scope) }
    end

    context "when discretion is granted" do
      let(:detail) { build_stubbed(:detail, discretion_applied: true) }

      it { is_expected.to eq I18n.t(true.to_s, scope: scope) }
    end

    context "when discretion is nil" do
      let(:detail) { build_stubbed(:detail, discretion_applied: nil) }

      it { is_expected.to be false }
    end

  end

  describe '#savings_passed?' do
    subject { view.savings_passed? }

    context "is true" do
      before do
        allow(application).to receive(:saving).and_return(saving)
        allow(saving).to receive_messages(passed?: true, passed: true)
      end

      it { is_expected.to eq I18n.t(true.to_s, scope: scope) }

      context 'override exists' do
        let(:decision_override) { build(:decision_override, application: application, reason: 'foo bar', id: 5) }
        let(:application) { build_stubbed(:application, :benefit_type) }

        before { decision_override }

        it { is_expected.to eq I18n.t(true.to_s, scope: scope) }
      end
    end

    describe '#allow_override?' do
      subject { view.allow_override? }
      context 'online application' do
        let(:application) { build_stubbed(:application, detail: detail, online_application_id: 3, benefits: benefits) }
        let(:benefits) { false }
        context 'saving failed' do
          before do
            allow(application).to receive(:saving).and_return(saving)
            allow(saving).to receive(:passed).and_return(false)
          end
          it { is_expected.to be true }

          context 'not a benefit application' do
            let(:benefits) { false }

            it { is_expected.to be true }
          end
        end

        context 'benefit application' do
          let(:benefits) { true }
          it { is_expected.to be false }
        end

      end

      context 'saving passed' do
        let(:application) { build_stubbed(:application, detail: detail, online_application_id: 3, benefits: false) }

        before do
          allow(application).to receive(:saving).and_return(saving)
          allow(saving).to receive(:passed).and_return(true)
        end
        it { is_expected.to be true }
      end

      context 'no saving present' do
        let(:application) { build_stubbed(:application, detail: detail, online_application_id: 3, benefits: false) }
        before do
          allow(application).to receive(:saving).and_return(saving)
          allow(saving).to receive(:passed).and_return(nil)
        end
        it { is_expected.to be true }
      end

      context 'saving failed' do
        before do
          allow(application).to receive(:saving).and_return(saving)
          allow(saving).to receive(:passed).and_return(false)
        end
        it { is_expected.to be false }
      end

    end

    context "is false" do
      before do
        allow(application).to receive(:saving).and_return(saving)
        allow(saving).to receive_messages(passed?: false, passed: false)
      end

      it { is_expected.to eq I18n.t(false.to_s, scope: scope) }
    end

    context 'and there is no saving' do
      let(:decision_override) { build(:decision_override, application: application, reason: 'foo bar', id: 5) }
      let(:application) { build_stubbed(:application, :income_type, benefits: nil) }

      before do
        allow(application).to receive(:saving).and_return(saving)
        allow(saving).to receive(:passed).and_return(nil)
        decision_override
      end

      it { is_expected.to be false }
    end

  end

  describe '#benefits_passed?' do
    subject { view.benefits_passed? }
    context 'when benefits is false' do
      let(:application) { build_stubbed(:application, :benefit_type, benefits: false) }

      it { is_expected.to be_nil }
    end

    context 'when benefits is true' do
      context 'and benefit_check returned yes' do
        let!(:benefit_check) { build_stubbed(:benefit_check, applicationable: application, dwp_result: 'Yes') }
        let!(:application) { build_stubbed(:application, :benefit_type) }
        before {
          allow(application).to receive(:last_benefit_check).and_return(benefit_check)
          allow(benefit_check).to receive(:passed?).and_return(true)
        }

        it { is_expected.to eq string_passed }
      end

      ['No', 'Undetermined', 'BadRequest'].each do |result|
        context "benefit_check returned #{result}" do
          let(:benefit_check) { build_stubbed(:benefit_check, applicationable: application, dwp_result: result) }
          let(:application) { build_stubbed(:application, :benefit_type) }
          before { allow(application).to receive(:last_benefit_check).and_return(benefit_check) }

          it { is_expected.to eq string_failed }
        end
      end
    end

    context 'when a benefit_override exists' do
      let(:benefit_check) { build_stubbed(:benefit_check, applicationable: application, dwp_result: 'No') }
      let(:application) { build_stubbed(:application, :benefit_type) }
      before {
        build_stubbed(:benefit_override, application: application, correct: value)
        allow(application).to receive(:last_benefit_check).and_return(benefit_check)
        allow(benefit_check).to receive(:passed?).and_return(false)
      }

      context 'and the evidence is correct' do
        let(:value) { true }

        it { is_expected.to eq I18n.t('activemodel.attributes.forms/application/summary.passed_with_evidence') }
      end

      context 'and the evidence is incorrect' do
        let(:value) { false }

        it { is_expected.to eq I18n.t('activemodel.attributes.forms/application/summary.failed') }
      end
    end

    context 'when a benefit_override does not exist' do
      describe 'and the application is online which failed the manual benefit check' do
        let(:online_application) { build_stubbed(:online_application, dwp_manual_decision: false, id: 654654) }
        let(:application) { build_stubbed(:application, :benefit_type, benefits: true, online_application_id: 654654, online_application: online_application) }
        let(:benefit_check) { build_stubbed(:benefit_check, applicationable: online_application, dwp_result: 'No') }
        before {
          allow(application).to receive(:last_benefit_check).and_return(benefit_check)
        }

        it { is_expected.to eq I18n.t('activemodel.attributes.forms/application/summary.failed') }
      end
    end

    context 'when a decision override exists' do
      let(:decision_override) { build(:decision_override, application: application, reason: 'foo bar', id: id) }
      let(:benefit_check) { build_stubbed(:benefit_check, applicationable: application, dwp_result: 'No') }
      before {
        decision_override
        allow(application).to receive(:last_benefit_check).and_return(benefit_check)
      }

      context 'but it is not saved' do
        let(:id) { nil }
        it { is_expected.not_to eq "✓ Passed (by manager's decision)" }
      end

      context 'and it is saved' do
        let(:id) { 5 }
        it { is_expected.to eq "✓ Passed (by manager's decision)" }
      end

      context 'but there is no benefit' do
        let(:application) { build_stubbed(:application, :income_type, benefits: nil) }
        let(:id) { 5 }
        it { is_expected.to be_nil }
      end
    end
  end

  describe '#income_passed?' do
    subject { view.income_passed? }

    let(:application) {
      build_stubbed(:application, :income_type,
                    state: state, outcome: outcome, income_max_threshold_exceeded: threshold_exceeded)
    }
    let(:threshold_exceeded) { nil }

    context 'when the application is a full remission' do
      let(:state) { 3 }
      let(:outcome) { 'full' }

      it { is_expected.to eq string_passed }
    end

    context 'when the application is a part remission' do
      let(:state) { 2 }
      let(:outcome) { 'part' }

      it { is_expected.to eq string_part_payment }
    end

    context 'when the application is a non remission' do
      let(:state) { 3 }
      let(:outcome) { 'none' }

      it { is_expected.to eq string_failed }
    end

    context 'decision_override' do
      let(:decision_override) { build(:decision_override, application: application, reason: 'foo bar', id: 5) }
      before { decision_override }
      let(:threshold_exceeded) { true }

      context 'when the application is a non remission' do
        let(:state) { 3 }
        let(:outcome) { 'none' }

        it { is_expected.to eq "✓ Passed (by manager's decision)" }
      end

    end
  end

  describe '#result' do
    subject { view.result }
    let(:application) {
      build_stubbed(:application, :income_type, state: state, outcome: outcome)
    }
    let(:state) { 3 }
    let(:outcome) { 'none' }

    context 'when an application has an evidence_check' do
      before { build_stubbed(:evidence_check, application: application, outcome: 'full') }

      it { is_expected.to eql 'full' }

      context 'and is in waiting for evidence state' do
        let(:state) { 1 }
        let(:outcome) { 'none' }

        it { is_expected.to eql 'callout' }
      end
    end

    context 'when outcome is nil' do
      before { application.outcome = nil }

      it { is_expected.to eql 'none' }
    end

    context 'when a decision override exists' do
      let(:decision_override) { build(:decision_override, application: application, reason: 'foo bar', id: id) }
      before { decision_override }

      context 'but it is not saved' do
        let(:id) { nil }
        it { is_expected.to eql 'none' }
      end

      context 'and it is valid' do
        let(:id) { 8 }
        it { is_expected.to eql 'granted' }
      end
    end
  end

  describe "#expires_at" do
    subject {
      Timecop.freeze(Date.new(2022, 1, 8)) {
        view.expires_at
      }
    }
    before { Settings.payment.expires_in_days = 1 }

    context 'application' do
      it { is_expected.to eql('9 January 2022') }
    end

    context 'evidence_check' do
      let(:evidence_check) { build(:evidence_check, expires_at: '10 January 2022') }
      let(:application) { build(:application, state: :processed, evidence_check: evidence_check) }

      it { is_expected.to eql('10 January 2022') }
    end

    context 'part_payment' do
      let(:evidence_check) { build(:evidence_check, expires_at: '10 January 2022') }
      let(:part_payment) { build(:part_payment, expires_at: '11 January 2022') }
      let(:application) { build(:application, state: :waiting_for_part_payment, evidence_check: evidence_check, part_payment: part_payment) }

      it { is_expected.to eql('11 January 2022') }
    end
  end

  describe "#income" do
    subject { view.income }
    let(:app_income) { 1200 }
    let(:ev_income) { 1400 }

    let(:application) {
      build_stubbed(:application, :income_type, income: app_income)
    }

    it { is_expected.to eql app_income }

    context 'evidence_check' do
      let(:application) { build_stubbed(:application, :income_type, income: app_income, evidence_check: evidence_check) }
      let(:evidence_check) { build_stubbed(:evidence_check, income: ev_income) }
      it { is_expected.to eql ev_income }
    end
  end
end
