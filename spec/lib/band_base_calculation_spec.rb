# frozen_string_literal: true

require 'rspec'

RSpec.describe BandBaseCalculation do
  let(:application) { build(:application, fee: fee, income: income, married: married, applicant: applicant, saving: saving) }
  let(:applicant) { build(:applicant, date_of_birth: dob) }
  let(:saving) { build(:saving, amount: saving_amount) }
  let(:income) { 1000 }
  let(:married) { false }
  let(:saving_amount) { nil }
  let(:fee) { 100 }
  let(:dob) { 20.years.ago }

  subject(:band_calculation) { described_class.new(application) }

  context 'saving_threshold_exceeded?' do
    # If fee is under 1420 then the capital threshold is 4250 aka 3*1420
    context 'Fee band 1' do
      context "0 fee and 0 saving" do
        let(:fee) { 0 }
        let(:saving_amount) { 0 }
        it { expect(band_calculation.saving_threshold_exceeded?).to be false }
      end
      context "1420 fee and 4250 saving" do
        let(:fee) { 1420 }
        let(:saving_amount) { 4250 }
        it { expect(band_calculation.saving_threshold_exceeded?).to be false }
      end
      context "1420 fee and 4251 saving" do
        let(:fee) { 1420 }
        let(:saving_amount) { 4251 }
        it { expect(band_calculation.saving_threshold_exceeded?).to be true }
      end
    end
    # If fee is between 1421 and 5000 then the capital threshold is  3*fee so max 15000
    context 'Fee band 2' do
      context "1421 fee and 2 saving" do
        let(:fee) { 1421 }
        let(:saving_amount) { 4251 }
        it { expect(band_calculation.saving_threshold_exceeded?).to be false }
      end
      context "saving equal to 3x in fees" do
        let(:fee) { 1421 }
        let(:saving_amount) { 4263 }
        it { expect(band_calculation.saving_threshold_exceeded?).to be true }
      end
      context "more then 3xfee in savings" do
        let(:fee) { 1421 }
        let(:saving_amount) { 4264 }
        it { expect(band_calculation.saving_threshold_exceeded?).to be true }
      end
    end
    # If fee is between more then 5001 then the capital threshold is 16000
    context 'Fee band 3' do
      context "1421 fee and 2 saving" do
        let(:fee) { 5001 }
        let(:saving_amount) { 10000 }
        it { expect(band_calculation.saving_threshold_exceeded?).to be false }
      end
      context "more then 3xfee in savings but still under threshold" do
        let(:fee) { 5005 }
        let(:saving_amount) { 15900 }
        it { expect(band_calculation.saving_threshold_exceeded?).to be false }
      end
      context "equal to max savings" do
        let(:fee) { 6000 }
        let(:saving_amount) { 16000 }
        it { expect(band_calculation.saving_threshold_exceeded?).to be false }
      end
      context "over threshold" do
        let(:fee) { 6000 }
        let(:saving_amount) { 16001 }
        it { expect(band_calculation.saving_threshold_exceeded?).to be true }
      end
    end
  end
end
