# coding: utf-8

require 'rails_helper'

RSpec.describe Views::Overview::Benefits do
  subject(:view) { described_class.new(application) }

  let(:application) { build_stubbed(:application) }

  describe '#all_fields' do
    subject { view.all_fields }

    it { is_expected.to eql ['on_benefits?'] }
  end

  describe '#on_benefits?' do
    subject { view.on_benefits? }

    let(:application) { build_stubbed :application, benefits: benefits }

    [true, false].each do |value|
      context "when benefits is #{value}" do
        let(:benefits) { value }

        it { is_expected.to eq I18n.t("convert_boolean.#{value}") }
      end
    end
  end

  describe '#override?' do
    subject { view.override? }

    context 'when a benefit_override exists' do
      before { build_stubbed(:benefit_override, application: application) }

      it { is_expected.to eq I18n.t('convert_boolean.true') }
    end

    context 'when no benefit_override exists' do
      it { is_expected.to eq I18n.t('convert_boolean.false') }
    end

    context 'when user selected "no" to on benefits' do
      let(:application) { build_stubbed :application, benefits: false }

      it { is_expected.to eq nil }
    end
  end

  describe '#override_valid?' do
    subject { view.override_valid? }

    context 'when a benefit_override exists' do
      [true, false].each do |value|
        context "and the evidence is #{value ? 'correct' : 'incorrect'}" do
          before { build_stubbed(:benefit_override, application: application, correct: value) }

          it { is_expected.to eq I18n.t("convert_boolean.#{value}") }
        end
      end
    end

    context 'when no benefit_override exists' do
      it { is_expected.to eq nil }
    end

    context 'when user selected "no" to on benefits' do
      let(:application) { build_stubbed :application, benefits: false }

      it { is_expected.to eq nil }
    end
  end
end
