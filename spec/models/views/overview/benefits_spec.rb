# coding: utf-8

require 'rails_helper'

RSpec.describe Views::Overview::Benefits do
  subject(:view) { described_class.new(application) }

  let(:application) { build_stubbed(:application) }

  describe '#all_fields' do
    subject { view.all_fields }

    it { is_expected.to eql ['on_benefits?', 'dwp_check_passed?', 'override?'] }
  end

  describe '#skip_change_link' do
    it 'hides the Change link on the DWP row only' do
      expect(view.skip_change_link).to eql ['dwp_check_passed?']
    end
  end

  describe '#on_benefits?' do
    subject { view.on_benefits? }

    let(:application) { build_stubbed(:application, benefits: benefits) }

    [true, false].each do |value|
      context "when benefits is #{value}" do
        let(:benefits) { value }

        it { is_expected.to eq I18n.t("convert_boolean.#{value}") }
      end
    end
  end

  # "DWP check passed" shows the DWP result; "Correct evidence provided" shows
  # the staff paper evidence answer, and only when the DWP check did not pass.
  # An override with no check counts as a failed check.
  describe 'evidence rows' do
    let(:application) { create(:application, benefits: true) }

    def create_check(dwp_result)
      create(:benefit_check, applicationable: application, dwp_result: dwp_result)
    end

    context 'when the DWP check said No and staff answered the evidence question' do
      before { create_check('No') }

      [true, false].each do |value|
        context "with #{value ? 'correct' : 'incorrect'} evidence" do
          before { create(:benefit_override, application: application, correct: value) }

          it { expect(view.dwp_check_passed?).to eq I18n.t('convert_boolean.false') }
          it { expect(view.override?).to eq I18n.t("convert_boolean.#{value}") }
        end
      end
    end

    context 'when the DWP check said Yes and there is no staff answer' do
      before { create_check('Yes') }

      it { expect(view.dwp_check_passed?).to eq I18n.t('convert_boolean.true') }
      it { expect(view.override?).to be_nil }
    end

    context 'when the DWP check said No and there is no staff answer' do
      before { create_check('No') }

      it { expect(view.dwp_check_passed?).to eq I18n.t('convert_boolean.false') }
      it { expect(view.override?).to be_nil }
    end

    context 'when the DWP check said Yes after an earlier "no evidence" answer' do
      before do
        create(:benefit_override, application: application, correct: false)
        create_check('Yes')
      end

      it { expect(view.dwp_check_passed?).to eq I18n.t('convert_boolean.true') }

      it 'hides the earlier staff answer' do
        expect(view.override?).to be_nil
      end
    end

    context 'when no DWP check ran and staff answered the evidence question' do
      before { create(:benefit_override, application: application, correct: true) }

      it 'treats the missing check as failed' do
        expect(view.dwp_check_passed?).to eq I18n.t('convert_boolean.false')
      end

      it { expect(view.override?).to eq I18n.t('convert_boolean.true') }
    end

    context 'when nothing was recorded' do
      it { expect(view.dwp_check_passed?).to be_nil }
      it { expect(view.override?).to be_nil }
    end

    context 'when user selected "no" to on benefits' do
      let(:application) { build_stubbed(:application, benefits: false) }

      it { expect(view.dwp_check_passed?).to be_nil }
      it { expect(view.override?).to be_nil }
    end
  end
end
