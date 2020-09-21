require 'rails_helper'

RSpec.describe ResultHelper, type: :helper do

  describe '#display_savings_failed_letter' do
    let(:application) { instance_double(Application) }
    let(:saving) { instance_double(Saving) }

    before do
      RSpec::Mocks.configuration.allow_message_expectations_on_nil
      allow(application).to receive(:saving).and_return saving
      allow(saving).to receive(:passed?).and_return passed
    end

    context 'failed savings' do
      let(:passed) { false }
      it { expect(helper.display_savings_failed_letter?(application)).to be true }
    end

    context 'passed savings' do
      let(:passed) { true }
      it { expect(helper.display_savings_failed_letter?(application)).to be false }
    end

    context 'no savings' do
      let(:saving) { nil }
      let(:passed) { nil }
      it { expect(helper.display_savings_failed_letter?(application)).to be false }
    end
  end

  describe '#display_benefit_failed_letter' do
    let(:application) { instance_double(Application) }
    let(:benefit_check) { instance_double(BenefitCheck) }
    let(:benefits) { true }
    let(:benefits_valid) { true }

    before do
      RSpec::Mocks.configuration.allow_message_expectations_on_nil
      allow(application).to receive(:benefits).and_return benefits
      allow(application).to receive(:benefit_checks).and_return [benefit_check]
      allow(benefit_check).to receive(:benefits_valid?).and_return benefits_valid
    end

    context 'application is not benefit based' do
      let(:benefits) { false }
      it { expect(helper.display_benefit_failed_letter?(application)).to be false }
    end

    context 'application has no benefit checks' do
      let(:benefit_check) { nil }
      it { expect(helper.display_benefit_failed_letter?(application)).to be false }
    end

    context 'application has valid benefit check' do
      let(:benefits_valid) { true }
      it { expect(helper.display_benefit_failed_letter?(application)).to be false }
    end

    context 'application has invalid benefit check' do
      let(:benefits_valid) { false }
      it { expect(helper.display_benefit_failed_letter?(application)).to be true }
    end
  end

  describe '#display_income_failed_letter' do
    let(:application) { instance_double(Application) }

    before do
      RSpec::Mocks.configuration.allow_message_expectations_on_nil
      allow(application).to receive(:income_max_threshold_exceeded).and_return income_max_threshold_exceeded
    end

    context 'max income threashold exceeded' do
      let(:income_max_threshold_exceeded) { true }
      it { expect(helper.display_income_failed_letter?(application)).to be true }
    end

    context 'max income threashold is not exceeded' do
      let(:income_max_threshold_exceeded) { false }
      it { expect(helper.display_income_failed_letter?(application)).to be false }
    end

    context 'max income threashold exceeded is blank' do
      let(:income_max_threshold_exceeded) { nil }
      it { expect(helper.display_income_failed_letter?(application)).to be false }
    end
  end

  describe '#income_value' do
    let(:application) {
      instance_double(Application, income: income,
                                   income_min_threshold_exceeded: income_min, income_max_threshold_exceeded: income_max,
                                   income_max_threshold: 6065.to_f)
    }
    let(:income_min) { false }
    let(:income_max) { false }

    before do
      RSpec::Mocks.configuration.allow_message_expectations_on_nil
    end

    context 'income is 0' do
      let(:income) { 0 }
      it { expect(helper.income_value(application)).to eq "£0.00" }
    end

    context 'income is a number' do
      let(:income) { 10.52 }
      it { expect(helper.income_value(application)).to eq '£10.52' }
    end

    context 'income threashold exceeded' do
      let(:income) { nil }
      let(:income_min) { true }
      let(:income_max) { true }

      it { expect(helper.income_value(application)).to eq '£6,065 or more' }
    end

    context 'max income threashold not exceeded' do
      let(:income) { nil }
      let(:income_min) { true }
      let(:income_max) { false }

      it { expect(helper.income_value(application)).to be nil }
    end
  end
end