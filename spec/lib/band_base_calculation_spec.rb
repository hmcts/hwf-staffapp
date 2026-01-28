# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BandBaseCalculation do
  let(:applicant) { build(:applicant, married: married) }
  let(:detail) { build(:detail, fee: fee) }
  let(:saving) { build(:saving, amount: saving_amount, over_66: over_66) }
  let(:income) { 0 }
  let(:married) { false }
  let(:saving_amount) { nil }
  let(:fee) { 100 }
  let(:over_66) { false }
  let(:children_age_band) { [] }
  let(:max_threshold_exceeded) { nil }

  let(:application) {
    build(:application, detail: detail, income: income,
                        applicant: applicant, saving: saving, children_age_band: children_age_band)
  }

  let(:online_application) {
    build(:online_application, fee: fee, income: income,
                               married: married, amount: saving_amount, children_age_band: children_age_band, over_66: over_66, max_threshold_exceeded: max_threshold_exceeded)
  }

  describe 'threshold in decimal' do
    subject(:band_calculation) { described_class.new(online_application) }
    context 'saving exceeded' do
      let(:fee) { 1420.99 }
      let(:income) { 1000 }
      let(:children_age_band) { {} }
      let(:saving_amount) { 4270 }
      let(:married) { false }
      let(:over_66) { false }

      it {
        expect(band_calculation.remission).to eq('none')
        expect(band_calculation.saving_passed?).to be false
      }
    end
  end

  describe 'rounding rst-6179' do
    subject(:band_calculation) { described_class.new(online_application) }

    context 'part 1722' do
      let(:fee) { 2000 }
      let(:income) { 4000 }
      let(:children_age_band) { {} }
      let(:saving_amount) { 1500 }
      let(:married) { false }
      let(:over_66) { false }

      it {
        expect(band_calculation.remission).to eq('part')
        expect(band_calculation.amount_to_pay).to eq(1722)
      }
    end

    context 'part 556' do
      let(:fee) { 800 }
      let(:income) { 2500 }
      let(:children_age_band) { {} }
      let(:saving_amount) { 1500 }
      let(:married) { false }
      let(:over_66) { false }

      it {
        expect(band_calculation.remission).to eq('part')
        expect(band_calculation.amount_to_pay).to eq(556)
      }
    end

    context 'part 591' do
      let(:fee) { 800 }
      let(:income) { 2553 }
      let(:children_age_band) { {} }
      let(:saving_amount) { 1500 }
      let(:married) { false }
      let(:over_66) { false }

      it {
        expect(band_calculation.remission).to eq('part')
        expect(band_calculation.amount_to_pay).to eq(591)
      }
    end

    context 'part 934' do
      let(:fee) { 1350 }
      let(:income) { 5314 }
      let(:children_age_band) { { 'one' => '2', 'two' => '1' } }
      let(:saving_amount) { 2000 }
      let(:married) { true }
      let(:over_66) { false }

      it {
        expect(band_calculation.remission).to eq('part')
        expect(band_calculation.amount_to_pay).to eq(934)
      }
    end

    context 'part 115' do
      let(:fee) { 300 }
      let(:income) { 3500 }
      let(:children_age_band) { { 'one' => '1', 'two' => '1' } }
      let(:saving_amount) { 1500 }
      let(:married) { true }
      let(:over_66) { false }

      it {
        expect(band_calculation.remission).to eq('part')
        expect(band_calculation.amount_to_pay).to eq(115)
      }
    end

    context 'part 290' do
      let(:fee) { 455 }
      let(:income) { 2005 }
      let(:children_age_band) { {} }
      let(:saving_amount) { 1500 }
      let(:married) { false }
      let(:over_66) { false }

      it {
        expect(band_calculation.remission).to eq('part')
        expect(band_calculation.amount_to_pay).to eq(290)
      }
    end

    context 'part 885' do
      let(:fee) { 1750 }
      let(:income) { 5818 }
      let(:children_age_band) { { 'one' => '0', 'two' => '3' } }
      let(:saving_amount) { 2000 }
      let(:married) { true }
      let(:over_66) { false }

      it {
        expect(band_calculation.remission).to eq('part')
        expect(band_calculation.amount_to_pay).to eq(885)
      }
    end

  end
  # based on documents for band calculation tickets
  describe 'amount to pay' do
    subject(:band_calculation) { described_class.new(online_application) }

    context 'part 490' do
      let(:fee) { 1421 }
      let(:income) { 4263 }
      let(:children_age_band) { { 'one' => '1', 'two' => '1' } }
      let(:saving_amount) { nil }
      let(:married) { true }
      let(:over_66) { false }

      it {
        expect(band_calculation.remission).to eq('part')
        expect(band_calculation.amount_to_pay).to eq(495)
      }
    end

    context 'part 1720' do
      let(:fee) { 2000 }
      let(:income) { 4000 }
      let(:children_age_band) { [] }
      let(:saving_amount) { nil }
      let(:married) { false }
      let(:over_66) { false }

      it {
        expect(band_calculation.remission).to eq('part')
        expect(band_calculation.amount_to_pay).to eq(1722)
      }
    end

    context 'part 290' do
      let(:fee) { 600 }
      let(:income) { 2000 }
      let(:children_age_band) { [] }
      let(:saving_amount) { nil }
      let(:married) { false }
      let(:over_66) { false }

      it {
        expect(band_calculation.remission).to eq('part')
        expect(band_calculation.amount_to_pay).to eq(290)
      }
    end

    context 'part 550' do
      let(:fee) { 800 }
      let(:income) { 2500 }
      let(:children_age_band) { [] }
      let(:saving_amount) { 15800 }
      let(:married) { false }
      let(:over_66) { true }

      it {
        expect(band_calculation.remission).to eq('part')
        expect(band_calculation.amount_to_pay).to eq(556)
      }
    end

    context 'full over 66 15800' do
      let(:fee) { 100 }
      let(:income) { 0 }
      let(:children_age_band) { [] }
      let(:saving_amount) { 15800 }
      let(:married) { true }
      let(:over_66) { true }

      it {
        expect(band_calculation.remission).to eq('full')
      }
    end

    context 'none over 66 16500' do
      let(:fee) { 100 }
      let(:income) { 0 }
      let(:children_age_band) { [] }
      let(:saving_amount) { 16500 }
      let(:married) { true }
      let(:over_66) { true }

      it {
        expect(band_calculation.remission).to eq('none')
        expect(band_calculation.amount_to_pay).to eq(100)
      }
    end

    context 'part 920' do
      let(:fee) { 1350 }
      let(:income) { 5300 }
      let(:children_age_band) { { one: 2, two: 1 } }
      let(:saving_amount) { nil }
      let(:married) { true }
      let(:over_66) { false }

      it {
        expect(band_calculation.remission).to eq('part')
        expect(band_calculation.amount_to_pay).to eq(927)
      }
    end

    context 'part 870' do
      let(:fee) { 1750 }
      let(:income) { 5800 }
      let(:children_age_band) { { one: 0, two: 3 } }
      let(:saving_amount) { 16000 }
      let(:married) { true }
      let(:over_66) { true }

      it {
        expect(band_calculation.remission).to eq('part')
        expect(band_calculation.amount_to_pay).to eq(878)
      }
    end

    context 'part 20' do
      let(:fee) { 150 }
      let(:income) { 1470 }
      let(:children_age_band) { [] }
      let(:saving_amount) { 0 }
      let(:married) { false }
      let(:over_66) { false }

      it {
        expect(band_calculation.remission).to eq('part')
        expect(band_calculation.amount_to_pay).to eq(25)
      }
    end

    context 'part 20 lower income' do
      let(:fee) { 125 }
      let(:income) { 1470 }
      let(:children_age_band) { [] }
      let(:saving_amount) { 0 }
      let(:married) { false }
      let(:over_66) { false }

      it {
        expect(band_calculation.remission).to eq('part')
        expect(band_calculation.amount_to_pay).to eq(25)
      }
    end

    context 'part 1740' do
      let(:fee) { 2150 }
      let(:income) { 5875 }
      let(:children_age_band) { { one: 1, two: 1 } }
      let(:saving_amount) { 0 }
      let(:married) { true }
      let(:over_66) { false }

      it {
        expect(band_calculation.remission).to eq('part')
        expect(band_calculation.amount_to_pay).to eq(1749)
      }
    end

    context 'part 1740 lower income' do
      let(:fee) { 2000 }
      let(:income) { 5875 }
      let(:children_age_band) { { one: 1, two: 1 } }
      let(:saving_amount) { 0 }
      let(:married) { true }
      let(:over_66) { false }

      it {
        expect(band_calculation.remission).to eq('part')
        expect(band_calculation.amount_to_pay).to eq(1749)
      }
    end

    context 'part 110' do
      let(:fee) { 300 }
      let(:income) { 3500 }
      let(:children_age_band) { { one: 1, two: 1 } }
      let(:saving_amount) { 0 }
      let(:married) { true }
      let(:over_66) { false }

      it {
        expect(band_calculation.remission).to eq('part')
        expect(band_calculation.amount_to_pay).to eq(115)
      }
    end

    context 'part 270 fee 10k' do
      let(:fee) { 10000 }
      let(:income) { 1972 }
      let(:children_age_band) { [] }
      let(:saving_amount) { nil }
      let(:married) { false }
      let(:over_66) { false }

      it {
        expect(band_calculation.remission).to eq('part')
        expect(band_calculation.amount_to_pay).to eq(275)
      }
    end

    context 'children and married - part 490' do
      let(:fee) { 1421 }
      let(:income) { 4263 }
      let(:children_age_band) { { one: 1, two: 1 } }
      let(:saving_amount) { 0 }
      let(:married) { true }
      let(:over_66) { false }
      it {
        expect(band_calculation.remission).to eq('part')
        expect(band_calculation.amount_to_pay).to eq 495
      }
    end

    context 'single full 500' do
      let(:fee) { 500 }
      let(:income) { 0 }
      let(:children_age_band) { [] }
      let(:saving_amount) { 0 }
      let(:married) { false }
      let(:over_66) { false }
      it {
        expect(band_calculation.remission).to eq('full')
        expect(band_calculation.amount_to_pay).to eq 0
        expect(band_calculation.income_failed?).to be false
      }
    end

    context 'single full 500 higher income' do
      let(:fee) { 500 }
      let(:income) { 1160 }
      let(:children_age_band) { [] }
      let(:saving_amount) { 0 }
      let(:married) { false }
      let(:over_66) { false }
      it {
        expect(band_calculation.remission).to eq('full')
        expect(band_calculation.amount_to_pay).to eq 0
      }
    end

    context 'married full 500' do
      let(:fee) { 500 }
      let(:income) { 1160 }
      let(:children_age_band) { [] }
      let(:saving_amount) { 0 }
      let(:married) { true }
      let(:over_66) { false }
      it {
        expect(band_calculation.remission).to eq('full')
        expect(band_calculation.amount_to_pay).to eq 0
      }
    end

    context 'married full 100' do
      let(:fee) { 100 }
      let(:income) { 1185 }
      let(:children_age_band) { [] }
      let(:saving_amount) { 0 }
      let(:married) { true }
      let(:over_66) { false }
      it {
        expect(band_calculation.remission).to eq('full')
        expect(band_calculation.amount_to_pay).to eq 0
      }
    end

    context 'single full fee 3500' do
      let(:fee) { 3500 }
      let(:income) { 0 }
      let(:children_age_band) { [] }
      let(:saving_amount) { 8100 }
      let(:married) { false }
      let(:over_66) { false }
      it {
        expect(band_calculation.remission).to eq('full')
      }
    end

    context 'single full fee 5500' do
      let(:fee) { 5500 }
      let(:income) { 0 }
      let(:children_age_band) { [] }
      let(:saving_amount) { 10500 }
      let(:married) { false }
      let(:over_66) { false }
      it {
        expect(band_calculation.remission).to eq('full')
      }
    end

    context 'single none fee 2200' do
      let(:fee) { 2200 }
      let(:income) { 0 }
      let(:children_age_band) { [] }
      let(:saving_amount) { 6900 }
      let(:married) { false }
      let(:over_66) { false }
      it {
        expect(band_calculation.remission).to eq('none')
        expect(band_calculation.amount_to_pay).to eq(2200)
      }
    end

    context 'single none 2150' do
      let(:fee) { 2150 }
      let(:income) { 5170 }
      let(:children_age_band) { [] }
      let(:saving_amount) { 0 }
      let(:married) { false }
      let(:over_66) { false }
      it {
        expect(band_calculation.remission).to eq('none')
        expect(band_calculation.amount_to_pay).to eq 2150
        expect(band_calculation.income_failed?).to be true
      }
    end

    context 'saving over threshold' do
      let(:fee) { 8250 }
      let(:income) { 1985 }
      let(:children_age_band) { {} }
      let(:saving_amount) { 16000 }
      let(:married) { true }
      let(:over_66) { false }

      it {
        expect(band_calculation.remission).to eq('none')
        expect(band_calculation.amount_to_pay).to eq(8250)
        expect(band_calculation.saving_passed?).to be false
      }
    end

  end

  describe 'Online application' do
    subject(:band_calculation) { described_class.new(online_application) }

    context 'remission' do
      context 'saving exceeded' do
        let(:fee) { 1421 }
        let(:saving_amount) { 4263 }
        it {
          expect(band_calculation.remission).to eq('none')
          expect(band_calculation.amount_to_pay).to eq(1421)
          expect(band_calculation.saving_passed?).to be false
          expect(band_calculation.income_failed?).to be false
        }
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
            it {
              expect(band_calculation.remission).to eq('none')
              expect(band_calculation.amount_to_pay).to eq(250)
              expect(band_calculation.income_failed?).to be true
            }
          end
        end

        context 'age cap over 66' do
          let(:over_66) { true }
          context 'under threshold' do
            let(:fee) { 150 }
            let(:saving_amount) { 10000 }
            let(:children_age_band) { [] }
            let(:married) { false }
            let(:income) { nil }
            it {
              expect(band_calculation.remission).to eq('full')
              expect(band_calculation.amount_to_pay).to eq 0
            }
          end
          context 'over threshold' do
            let(:fee) { 232 }
            let(:saving_amount) { 16500 }
            it {
              expect(band_calculation.remission).to eq('none')
              expect(band_calculation.amount_to_pay).to eq(232)
            }
          end

        end

        context 'negative part payment single no children income 2200' do
          let(:over_66) { false }
          let(:children_age_band) { {} }
          let(:married) { false }
          let(:fee) { 100 }
          let(:income) { 2200 }
          let(:saving_amount) { 0 }
          it {
            expect(band_calculation.remission).to eq('none')
            expect(band_calculation.amount_to_pay).to eq(100)
          }
        end

        context 'negative part payment single no children income 4800' do
          let(:over_66) { false }
          let(:children_age_band) { {} }
          let(:married) { true }
          let(:fee) { 205 }
          let(:income) { 4800 }
          let(:saving_amount) { 0 }
          it {
            expect(band_calculation.remission).to eq('none')
            expect(band_calculation.amount_to_pay).to eq(205)
          }
        end

        context 'over capital threshold' do
          let(:date_of_birth) { 40.years.ago }
          let(:fee) { 1500 }
          let(:saving_amount) { 10000 }
          it {
            expect(band_calculation.remission).to eq('none')
            expect(band_calculation.amount_to_pay).to eq(1500)
          }
        end

        context 'amount emptu but max_threshold_exceeded' do
          let(:date_of_birth) { 40.years.ago }
          let(:fee) { 1500 }
          let(:saving_amount) { 0 }
          let(:max_threshold_exceeded) { true }
          it {
            expect(band_calculation.remission).to eq('none')
            expect(band_calculation.amount_to_pay).to eq(1500)
          }
        end

        context 'premiums' do
          let(:saving_amount) { 0 }
          context 'children and married none - over max income cap' do
            let(:fee) { 1350 }
            let(:income) { 6560 }
            let(:children_age_band) { { 'two' => '2' } }
            let(:married) { true }
            it {
              expect(band_calculation.remission).to eq('none')
              expect(band_calculation.amount_to_pay).to eq(1350)
            }
          end
        end
      end
    end
  end

  describe 'Paper application' do
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
        before { band_calculation.remission }
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
          let(:saving_amount) { 15999 }
          it { expect(band_calculation.saving_threshold_exceeded?).to be false }
        end
        context "over threshold" do
          let(:fee) { 6000 }
          let(:saving_amount) { 16001 }
          it {
            expect(band_calculation.saving_threshold_exceeded?).to be true
            expect(band_calculation.amount_to_pay).to eq(6000)
          }
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
        let(:children_age_band) { { one: 1 } }
        let(:married) { false }
        it { expect(band_calculation.premiums).to eq(425) }
      end

      context "age band 2 single" do
        let(:children_age_band) { { two: 1 } }
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
        let(:children_age_band) { { one: 1, two: 2 } }

        let(:married) { true }
        it { expect(band_calculation.premiums).to eq(2555) }
      end
    end

    context 'remission' do
      context 'saving exceeded' do
        let(:fee) { 1421 }
        let(:saving_amount) { 4263 }
        it {
          expect(band_calculation.remission).to eq('none')
          expect(band_calculation.amount_to_pay).to eq(1421)
        }
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
            it {
              expect(band_calculation.remission).to eq('none')
              expect(band_calculation.amount_to_pay).to eq(250)
            }
          end

          context "no children married over 66" do
            let(:children_age_band) { nil }
            let(:married) { false }
            let(:fee) { 10 }
            let(:over_66) { true }
            let(:income) { nil }
            let(:saving_amount) { 0 }
            it {
              expect(band_calculation.remission).to eq('full')
              expect(band_calculation.amount_to_pay).to eq(0)
            }
          end

        end

        context 'age cap over 66' do
          let(:over_66) { true }
          context 'under threshold' do
            let(:fee) { 150 }
            let(:saving_amount) { 10000 }
            it {
              expect(band_calculation.remission).to eq('full')
              expect(band_calculation.amount_to_pay).to eq(0)
            }
          end
          context 'over threshold' do
            let(:fee) { 232 }
            let(:saving_amount) { 16500 }
            it {
              expect(band_calculation.remission).to eq('none')
              expect(band_calculation.amount_to_pay).to eq(232)
            }
          end

        end

        context 'over capital threshold' do
          let(:over_66) { false }
          let(:fee) { 1500 }
          let(:saving_amount) { 10000 }
          it {
            expect(band_calculation.remission).to eq('none')
            expect(band_calculation.amount_to_pay).to eq(1500)
          }
        end

        context 'over capital threshold with no over_66 data' do
          let(:over_66) { nil }
          let(:fee) { 1500 }
          let(:saving_amount) { 10000 }
          it {
            expect(band_calculation.remission).to eq('none')
            expect(band_calculation.amount_to_pay).to eq(1500)
          }
        end

        context 'premiums' do
          context 'children and married none - over max income cap' do
            let(:fee) { 1350 }
            let(:income) { 6560 }
            let(:children_age_band) { { two: 2 } }
            let(:married) { true }
            it {
              expect(band_calculation.remission).to eq('none')
              expect(band_calculation.amount_to_pay).to eq(1350)
            }
          end

          context 'single 2 children on the edge of band 1' do
            let(:fee) { 593 }
            let(:income) { 3705 }
            let(:children_age_band) { { one: 1, two: 1 } }
            let(:married) { false }
            it {
              expect(band_calculation.remission).to eq('none')
              expect(band_calculation.amount_to_pay).to eq(593)
            }
          end

          context 'married 2 children full remission 1350 fee' do
            let(:fee) { 1350 }
            let(:income) { 3260 }
            let(:children_age_band) { { one: 1, two: 1 } }
            let(:married) { true }
            it {
              expect(band_calculation.remission).to eq('full')
              expect(band_calculation.amount_to_pay).to eq(0)
            }
          end

          context 'married 2 children none remission 90 fee' do
            let(:fee) { 90 }
            let(:income) { 3200 }
            let(:children_age_band) { { one: 2, two: 0 } }
            let(:married) { true }

            it {
              expect(band_calculation.remission).to eq('none')
              expect(band_calculation.amount_to_pay).to eq(90)
            }
          end

        end

      end
    end
  end

end
