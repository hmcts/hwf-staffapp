# frozen_string_literal: true

require 'rspec'

RSpec.describe BandBaseCalculation do
  let(:application) { spy(Application, detail: detail, income: income,
                                      applicant: applicant, saving: saving, children_age_band: children_age_band) }
  let(:applicant) { build(:applicant, date_of_birth: date_of_birth, married: married) }
  let(:detail) { build(:detail, fee: fee) }
  let(:saving) { build(:saving, amount: saving_amount) }
  let(:income) { 1000 }
  let(:married) { false }
  let(:saving_amount) { nil }
  let(:fee) { 100 }
  let(:date_of_birth) { 20.years.ago }
  let(:children_age_band) { [1] }
  before { allow(application).to receive(:children_age_band).and_return children_age_band }

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

  context 'income band calculation' do
    context 'min threshold' do
      context "0 income" do
        let(:income) { 0 }
        it { expect(band_calculation.income_band(income)).to eq(0) }
      end
      context "min threshold income" do
        let(:income) { 1420 }
        it { expect(band_calculation.income_band(income)).to eq(0) }
      end
    end
    context 'bands' do
      context "1421 band 1" do
        let(:income) { 1421 }
        it { expect(band_calculation.income_band(income)).to eq(1) }
      end
      context "2421 band 2" do
        let(:income) { 2421 }
        it { expect(band_calculation.income_band(income)).to eq(2) }
      end
      context "3420 band 2" do
        let(:income) { 3420 }
        it { expect(band_calculation.income_band(income)).to eq(2) }
      end
      context "3421 band 3" do
        let(:income) { 3421 }
        it { expect(band_calculation.income_band(income)).to eq(3) }
      end
      context "4420 income" do
        let(:income) { 4420 }
        it { expect(band_calculation.income_band(income)).to eq(3) }
      end
      context "over max threshold" do
        let(:income) { 4421 }
        it { expect(band_calculation.income_band(income)).to eq(-1) }
      end
    end
  end

  context 'income_calculation' do
    # min threshold 1420
    # band 1: 50% of income
    # band 2: 50% of band 1 income and 70% of income over
    # band 3: 50% of band 1 income and 70% of band 2 income and 90% income over

    context "band 1 income 1421" do
      let(:income) { 1421 }
      let(:band) { 1 }
      it { expect(band_calculation.income_calculation(band, income)).to eq(710.5) }
    end
    context "band 2 and income 2500" do
      let(:income) { 2500 }
      let(:band) { 2 }
      it { expect(band_calculation.income_calculation(band, income)).to eq(1550.0) }
    end
    context "band 3 and income 3500" do
      let(:income) { 3500 }
      let(:band) { 3 }
      it { expect(band_calculation.income_calculation(band, income)).to eq(2550.0) }
    end
  end

  context 'premiums' do
    # married: 710
    # child_band_1(0-13): 425
    # child_band_2(14+): 710

    context "age band 1 single" do
      let(:children_age_band) { [1] }
      let(:married) { false }
      it { expect(band_calculation.premiums).to eq(425) }
    end

    context "age band 2 single" do
      let(:children_age_band) { [2] }
      let(:married) { false }
      it { expect(band_calculation.premiums).to eq(710) }
    end

    context "no children married" do
      let(:children_age_band) { nil }
      let(:married) { true }
      it { expect(band_calculation.premiums).to eq(710) }
    end

    context "no children single" do
      let(:children_age_band) { nil }
      let(:married) { false }
      it { expect(band_calculation.premiums).to eq(0) }
    end

    context "band 1, band 2, band 2 and married" do
      let(:children_age_band) { [1,2,2]  }
      let(:married) { true }
      it { expect(band_calculation.premiums).to eq(2555) }
    end
  end

  context 'remission' do
    context 'saving exceeded' do
      let(:fee) { 1421 }
      let(:saving_amount) { 4263 }
      it { expect(band_calculation.remission).to eq('none') }
    end

    context 'saving within range' do
      let(:saving_amount) { 0 }

      context 'no premiums' do
        let(:married) { false }
        let(:children_age_band) { [] }

        context 'eligible' do
          let(:fee) { 232 }
          let(:income) { 1400 }
          it { expect(band_calculation.remission).to eq('full') }
        end
        context 'not eligible' do
          let(:fee) { 250 }
          let(:income) { 5500 }
          it { expect(band_calculation.remission).to eq('none') }
        end
        context 'part 280' do
          let(:fee) { 2000 }
          let(:income) { 4000 }
          it {
            expect(band_calculation.remission).to eq('part')
            expect(band_calculation.part_remission).to eq(280)
          }
        end
        context 'part 310' do
          let(:fee) { 600 }
          let(:income) { 2000 }
          it {
            expect(band_calculation.remission).to eq('part')
            expect(band_calculation.part_remission).to eq(310)
          }
        end
      end

      context 'age cap over 66' do
        let(:date_of_birth) { 67.years.ago }
        context 'under threshold' do
          let(:fee) { 150 }
          let(:saving_amount) { 10000 }
          it { expect(band_calculation.remission).to eq('full') }
        end
        context 'over threshold' do
          let(:fee) { 232 }
          let(:saving_amount) { 16500 }
          it { expect(band_calculation.remission).to eq('none') }
        end

        # context 'over capital threshold ' do
        #   let(:fee) { 1500 }
        #   let(:saving_amount) { 10000 }
        #   it { expect(band_calculation.remission).to eq('none') }
        # end
      end

      context 'premiums' do
        let(:saving_amount) { 0 }
        context 'children and married - full' do
          let(:fee) { 1421 }
          let(:income) { 4263 }
          let(:children_age_band) { [1,2] }
          let(:married) { true }
          it { expect(band_calculation.remission).to eq('full') }
        end
        context 'children and married none - over max income cap' do
          let(:fee) { 1350 }
          let(:income) { 6560 }
          let(:children_age_band) { [2,2] }
          let(:married) { true }
          it { expect(band_calculation.remission).to eq('none') }
        end

        context 'children and married - part ' do
          let(:fee) { 1350 }
          let(:income) { 5300 }
          let(:children_age_band) { [1,1,2] }
          let(:married) { true }
          it {
            expect(band_calculation.remission).to eq('part')
            expect(band_calculation.part_remission).to eq(430)
          }
        end
      end

    end
  end
end
# min_threshold = 1420
# max_threshold = 3000

# remissions(income, fee, married, kids)
# remissions(3200, 183, true, [10,15])
# remissions(6560, 1350, true, [16,17])
# remissions(5300, 1350, true, [10,13,15])
#
# remissions(1400, 232, true, [])
# remissions(5500, 250, true, [])
# remissions(4000, 2000, true, [])
# remissions(2000, 600, true, [])