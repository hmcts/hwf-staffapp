# coding: utf-8

require 'rails_helper'

RSpec.describe Views::ApplicationResult do
  subject(:view) { described_class.new(application) }

  let(:application) { build_stubbed(:application) }
  let(:string_passed) { 'Passed' }
  let(:string_failed) { 'Failed' }

  describe '#amount_to_pay' do
    subject { view.amount_to_pay }

    shared_examples 'amount_to_pay examples' do
      context 'displays the decimal' do
        let(:amount) { 100.49 }

        it 'formats the fee amount correctly' do
          is_expected.to eq '£100.49'
        end
      end

      context 'hides the decimal if the amount does not have one' do
        let(:amount) { 103 }

        it 'formats the fee amount correctly' do
          is_expected.to eq '£103'
        end
      end

      context 'when its under £1' do
        let(:amount) { 0.49 }

        it 'formats the fee amount correctly' do
          is_expected.to eq '£0.49'
        end
      end

      context 'returns nil if amount_to_pay is nil' do
        let(:amount) { nil }

        it 'returns nil' do
          is_expected.to be_nil
        end
      end
    end

    context 'when the application has evidence check' do
      let(:evidence) { build_stubbed(:evidence_check, amount_to_pay: amount) }
      let(:application) { build_stubbed(:application, evidence_check: evidence, amount_to_pay: nil) }

      it_behaves_like 'amount_to_pay examples'
    end

    context 'when the application does not have evidence check' do
      let(:application) { build_stubbed(:application, amount_to_pay: amount) }

      it_behaves_like 'amount_to_pay examples'
    end
  end

  describe '#result' do
    subject { view.result }

    shared_examples 'result examples' do |type|
      ['granted', 'full', 'part', 'none', 'return'].each do |result|
        context "when the #{type} is a #{result} remission" do
          let(:outcome) { result }

          it { is_expected.to eq result }
        end
      end

      context "for an unknown #{type} outcome" do
        let(:outcome) { 'unknown' }

        it { is_expected.to eq 'error' }
      end
    end

    context 'when the application has evidence check' do
      let(:evidence) { build_stubbed(:evidence_check, outcome: outcome) }
      let(:application) { build_stubbed(:application, evidence_check: evidence, outcome: nil) }

      it_behaves_like 'result examples', 'evidence'
    end

    context 'when the application does not have evidence check' do
      let(:application) { build_stubbed(:application, outcome: outcome) }

      it_behaves_like 'result examples', 'application'
    end

    context 'when the application has a completed part-payment' do
      let(:part_payment) { build_stubbed(:part_payment, outcome: 'part', correct: true) }
      let(:application) { build_stubbed(:application, part_payment: part_payment, outcome: 'part', amount_to_pay: 200) }

      it { is_expected.to eq 'paid' }

      it 'returns amount_to_refund based on evidence_check' do
        expect(view.amount_to_refund.to_i).to be(110)
      end
    end

    context 'when the application has a completed part-payment and evidence check' do
      let(:part_payment) { build_stubbed(:part_payment, outcome: 'part', correct: true) }
      let(:evidence) { build_stubbed(:evidence_check, outcome: 'part', amount_to_pay: 123) }
      let(:application) { build_stubbed(:application, part_payment: part_payment, outcome: 'part', evidence_check: evidence, amount_to_pay: 222, fee: 310) }

      it { is_expected.to eq 'paid' }

      it 'returns amount_to_pay' do
        expect(view.amount_to_pay).to eql("£123")
      end

      it 'returns amount_to_refund based on evidence_check' do
        expect(view.amount_to_refund.to_i).to be(187)
      end

      it 'returns refund false' do
        expect(view.refund).to be(false)
      end

      context 'refund' do
        let(:application) { build_stubbed(:application, refund: true) }

        it 'returns refund true' do
          expect(view.refund).to be(true)
        end
      end

    end
  end

  describe '#savings' do
    subject { view.savings }

    before do
      allow(application.saving).to receive(:passed?).and_return(savings_valid)
    end

    context 'when savings and investment is valid' do
      let(:savings_valid) { true }

      it { is_expected.to eql(string_passed) }
    end

    context 'when savings and investment is not valid' do
      let(:savings_valid) { false }

      it { is_expected.to eql(string_failed) }
    end
  end

  describe '#income' do
    subject { view.income }

    shared_examples 'result examples' do |type|
      ['full', 'part'].each do |outcome|
        context "when #{type} result is #{outcome}" do
          let(:outcome) { outcome }

          it { is_expected.to eql(string_passed) }
        end
      end

      context "when #{type} result is something else" do
        let(:outcome) { 'none' }

        it { is_expected.to eql(string_failed) }
      end
    end

    context 'when the application has evidence check' do
      let(:evidence) { build_stubbed(:evidence_check, outcome: outcome) }
      let(:application) { build_stubbed(:application, evidence_check: evidence, outcome: nil) }

      it_behaves_like 'result examples', 'evidence'
    end

    context 'when the application has evidence check but evidence check has no outcome' do
      let(:evidence) { build_stubbed(:evidence_check, outcome: nil) }
      let(:application) { build_stubbed(:application, evidence_check: evidence, outcome: 'none') }

      it { expect(view.result).to eq 'none' }
    end

    context 'when the application does not have evidence check' do
      let(:application) { build_stubbed(:application, outcome: outcome) }

      it_behaves_like 'result examples', 'application'
    end
  end

  describe '#return_type' do
    subject { view.return_type }

    let(:application) { build_stubbed(:application, decision_type: decision_type, outcome: 'none') }

    context 'when the application has no decision_type' do
      let(:decision_type) { nil }

      it { is_expected.to be_nil }
    end

    context 'when the application was decided by application' do
      let(:decision_type) { 'application' }

      it { is_expected.to be_nil }
    end

    context 'when the application was decided by evidence check' do
      let(:decision_type) { 'evidence_check' }

      it { is_expected.to eql('evidence') }
    end

    context 'when the application was decided by part_payment' do
      let(:decision_type) { 'part_payment' }

      it { is_expected.to eql('payment') }
    end
  end

  describe '#processed_part_payment?' do
    subject { view.processed_part_payment? }

    context 'when the application has a part payment and is processed' do
      let(:part_payment) { build_stubbed(:part_payment) }
      let(:application) { build_stubbed(:application, part_payment: part_payment, state: 3) }

      it { is_expected.to be true }
    end

    context 'when the application has no part payment' do
      let(:application) { build_stubbed(:application, part_payment: nil, state: 3) }

      it { is_expected.to be false }
    end

    context 'when the application is not processed' do
      let(:part_payment) { build_stubbed(:part_payment) }
      let(:application) { build_stubbed(:application, part_payment: part_payment, state: 2) }

      it { is_expected.to be false }
    end
  end

  describe '#banner_style' do
    subject { view.banner_style }

    context 'when the application has a processed part payment' do
      let(:part_payment) { build_stubbed(:part_payment) }
      let(:application) { build_stubbed(:application, part_payment: part_payment, state: 3, decision: 'full', outcome: 'part') }

      it 'returns the application decision' do
        is_expected.to eq 'full'
      end
    end

    context 'when the application has no part payment' do
      let(:application) { build_stubbed(:application, part_payment: nil, outcome: 'granted') }

      it 'returns the result' do
        is_expected.to eq 'granted'
      end
    end

    context 'when the application is not processed' do
      let(:part_payment) { build_stubbed(:part_payment) }
      let(:application) { build_stubbed(:application, part_payment: part_payment, state: 2, decision: 'none', outcome: 'part') }

      it 'returns the result' do
        is_expected.to eq 'part'
      end
    end
  end

  describe '#pp_outcome' do
    subject { view.pp_outcome }

    context 'when the part payment is successful' do
      let(:part_payment) { build_stubbed(:part_payment, correct: true, outcome: 'part') }
      let(:application) { build_stubbed(:application, part_payment: part_payment) }

      it 'returns paid' do
        is_expected.to eq 'paid'
      end
    end

    context 'when the part payment is not successful' do
      let(:part_payment) { build_stubbed(:part_payment, correct: false, outcome: 'none') }
      let(:application) { build_stubbed(:application, part_payment: part_payment) }

      it 'returns the part payment outcome' do
        is_expected.to eq 'none'
      end
    end

    context 'when there is no part payment' do
      let(:application) { build_stubbed(:application, part_payment: nil) }

      it 'returns nil' do
        is_expected.to be_nil
      end
    end
  end
end
