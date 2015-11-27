# coding: utf-8
require 'rails_helper'

RSpec.describe Views::Overview::SavingsAndInvestments do

  let(:application) { build_stubbed(:application) }
  subject(:view) { described_class.new(application) }

  describe '#all_fields' do
    subject { view.all_fields }
    it { is_expected.to eql %w[savings_valid? partner_over_61? combined_savings_valid?] }
  end

  describe '#savings_valid?' do
    let(:application) { build_stubbed :application, threshold_exceeded: threshold_exceeded }
    subject { view.savings_valid? }

    [true, false].each do |value|
      context "when threshold_exceeded is #{value}" do
        let(:threshold_exceeded) { value }
        it { is_expected.to eq I18n.t("convert_boolean.#{!value}") }
      end
    end
  end

  describe '#partner_over_61?' do
    let(:application) { build_stubbed :married_applicant_under_61, threshold_exceeded: true, partner_over_61: partner_over_61 }
    subject { view.partner_over_61? }

    [true, false].each do |state|
      context "when partner_over_61 is #{state}" do
        let(:partner_over_61) { state }

        it { is_expected.to eq I18n.t("convert_boolean.#{state}") }
      end
    end

    context 'when user selected "no" to threshold_exceeded' do
      let(:application) { build_stubbed :married_applicant_under_61, threshold_exceeded: false }

      it { is_expected.to eq nil }
    end
  end

  describe '#combined_savings_valid?' do
    let(:application) { build_stubbed :married_applicant_under_61, threshold_exceeded: true, high_threshold_exceeded: high_threshold_exceeded }
    subject { view.combined_savings_valid? }

    [true, false].each do |state|
      context "when high_threshold_exceeded is #{state}" do
        let(:high_threshold_exceeded) { state }

        it { is_expected.to eq I18n.t("convert_boolean.#{!state}") }
      end
    end

    context 'when user selected "no" to threshold_exceeded' do
      let(:application) { build_stubbed :married_applicant_under_61, threshold_exceeded: false }

      it { is_expected.to eq nil }
    end
  end
end
