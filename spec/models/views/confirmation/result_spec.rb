# coding: utf-8
require 'rails_helper'

RSpec.describe Views::Confirmation::Result do
  let(:application) { build_stubbed(:application) }
  let(:string_passed) { '✓ Passed' }
  let(:string_failed) { '✗ Failed' }
  let(:scope) { 'convert_pass_fail' }
  subject(:view) { described_class.new(application) }

  describe '#all_fields' do
    subject { view.all_fields }

    it { is_expected.to eql %w[savings_passed? benefits_passed? income_passed?] }
  end

  describe '#savings_passed?' do
    subject { view.savings_passed? }
    [true, false].each do |value|
      context "when threshold_exceeded is #{value}" do
        let(:application) { build_stubbed(:application, threshold_exceeded: value) }

        it { is_expected.to eq I18n.t(!value, scope: scope) }
      end
    end
  end

  describe '#benefits_passed?' do
    subject { view.benefits_passed? }
    context 'when benefits is false' do
      let(:application) { build_stubbed(:application, :benefit_type, benefits: false) }

      it { is_expected.to eq string_failed }
    end

    context 'when benefits is true' do
      context 'and benefit_check returned yes' do
        let!(:benefit_check) { build_stubbed(:benefit_check, application: application, dwp_result: 'Yes') }
        let!(:application) { build_stubbed(:application, :benefit_type) }
        before { allow(application).to receive(:last_benefit_check).and_return(benefit_check) }

        it { is_expected.to eq string_passed }
      end

      %w[No Undetermined].each do |result|
        context "benefit_check returned #{result}" do
          let(:benefit_check) { build_stubbed(:benefit_check, application: application, dwp_result: result) }
          let(:application) { build_stubbed(:application, :benefit_type) }
          before { allow(application).to receive(:last_benefit_check).and_return(benefit_check) }

          it { is_expected.to eq string_failed }
        end
      end
    end

    context 'when a benefit_override exists' do
      let!(:benefit_override) { build_stubbed(:benefit_override, application: application, correct: value) }

      context 'and the evidence is correct' do
        let(:value) { true }

        it { is_expected.to eq I18n.t('activemodel.attributes.forms/application/summary.passed_with_evidence') }
      end

      context 'and the evidence is incorrect' do
        let(:value) { false }

        it { is_expected.to eq string_failed }
      end
    end
  end

  describe '#income_passed?' do
    let(:application) { build_stubbed(:application, :income_type, outcome: outcome) }

    subject { view.income_passed? }

    context 'when the application is a full remission' do
      let(:outcome) { 'full' }

      it { is_expected.to eq '✓ Passed' }
    end

    context 'when the application is a part remission' do
      let(:outcome) { 'part' }

      it { is_expected.to eq '✓ Passed' }
    end

    context 'when the application is a non remission' do
      let(:outcome) { 'none' }

      it { is_expected.to eq '✗ Failed' }
    end
  end

  describe '#result' do
    subject { view.result }

    context 'when an application has an evidence_check' do
      before { allow(application).to receive(:evidence_check?).and_return(true) }

      it { is_expected.to eql 'callout' }
    end

    context 'when an application has had benefits overridden' do
      let!(:benefit_override) { build_stubbed :benefit_override, application: application, correct: evidence_correct }

      context 'and the correct evidence was provided' do
        let(:evidence_correct) { true }

        it { is_expected.to eql 'full' }
      end
    end

    context 'when outcome is nil' do
      before { application.outcome = nil }

      it { is_expected.to eql 'none' }
    end
  end
end
