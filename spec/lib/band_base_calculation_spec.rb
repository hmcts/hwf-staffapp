# frozen_string_literal: true

require 'rspec'

RSpec.describe BandBaseCalculation do
  let(:applicant) { build(:applicant, married: married) }
  let(:detail) { build(:detail, fee: fee) }
  let(:saving) { build(:saving, amount: saving_amount, over_66: over_66) }
  let(:income) { 1000 }
  let(:married) { false }
  let(:saving_amount) { nil }
  let(:fee) { 100 }
  let(:over_66) { false }
  let(:children_age_band) { { one: 2, two: 3 } }

  let(:application) {
    build(:application, detail: detail, income: income,
                        applicant: applicant, saving: saving, children_age_band: children_age_band)
  }

  let(:online_application) {
    build(:online_application, fee: fee, income: income,
                               married: married, amount: saving_amount, children_age_band: children_age_band, over_66: over_66)
  }

  describe 'Online application' do
    subject(:band_calculation) { described_class.new(online_application) }

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
          context 'part 1720' do
            let(:fee) { 2000 }
            let(:income) { 4000 }
            it {
              expect(band_calculation.remission).to eq('part')
              expect(band_calculation.amount_to_pay).to eq(1720)
            }
          end
          context 'part 310' do
            let(:fee) { 600 }
            let(:income) { 2000 }
            it {
              expect(band_calculation.remission).to eq('part')
              expect(band_calculation.amount_to_pay).to eq(290)
            }
          end
        end

        context 'age cap over 66' do
          let(:over_66) { true }
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

          context 'part payment with children' do
            let(:children_age_band) { { 'two' => '3' } }
            let(:married) { true }
            let(:fee) { 1750 }
            let(:income) { 5800 }
            let(:saving_amount) { 16000 }
            it {
              expect(band_calculation.remission).to eq('part')
              expect(band_calculation.amount_to_pay).to eq(870)
            }
          end

          context 'part payment single no children' do
            let(:children_age_band) { {} }
            let(:married) { false }
            let(:fee) { 800 }
            let(:income) { 2500 }
            let(:saving_amount) { 15800 }
            it {
              expect(band_calculation.remission).to eq('part')
              expect(band_calculation.amount_to_pay).to eq(550)
            }
          end

          context 'part payment single no children fee 150' do
            let(:children_age_band) { {} }
            let(:married) { false }
            let(:fee) { 150 }
            let(:income) { 1470 }
            let(:saving_amount) { 0 }
            it {
              expect(band_calculation.remission).to eq('part')
              expect(band_calculation.amount_to_pay).to eq(20)
            }
          end

          context 'part payment married 2 children' do
            let(:children_age_band) { { 'one' => '1', 'two' => '1' } }
            let(:married) { true }
            let(:fee) { 2150 }
            let(:income) { 5875 }
            let(:saving_amount) { 0 }
            it {
              expect(band_calculation.remission).to eq('part')
              expect(band_calculation.amount_to_pay).to eq(1740)
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
          it { expect(band_calculation.remission).to eq('none') }
        end

        context 'premiums' do
          let(:saving_amount) { 0 }
          context 'children and married - full' do
            let(:fee) { 1421 }
            let(:income) { 4263 }
            let(:children_age_band) { { 'one' => '1', 'two' => '1' } }
            let(:married) { true }
            it { expect(band_calculation.remission).to eq('full') }
          end
          context 'children and married none - over max income cap' do
            let(:fee) { 1350 }
            let(:income) { 6560 }
            let(:children_age_band) { { 'two' => '2' } }
            let(:married) { true }
            it { expect(band_calculation.remission).to eq('none') }
          end

          context 'children and married - part' do
            let(:fee) { 1350 }
            let(:income) { 5300 }
            let(:children_age_band) { { 'one' => '2', 'two' => '1' } }
            let(:married) { true }
            it {
              expect(band_calculation.remission).to eq('part')
              expect(band_calculation.amount_to_pay).to eq(920)
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
              expect(band_calculation.amount_to_pay).to eq(1720)
            }
          end
          context 'part 290' do
            let(:fee) { 600 }
            let(:amount) { nil }
            let(:income) { 2000 }
            it {
              expect(band_calculation.remission).to eq('part')
              expect(band_calculation.amount_to_pay).to eq(290)
            }
          end
          context 'part 270' do
            let(:fee) { 10000 }
            let(:amount) { nil }
            let(:income) { 1972 }
            it {
              expect(band_calculation.remission).to eq('part')
              expect(band_calculation.amount_to_pay).to eq(270)
            }
          end

          context "no children single over 66" do
            let(:children_age_band) { nil }
            let(:married) { false }
            let(:fee) { 100 }
            let(:over_66) { true }
            let(:income) { 0 }
            let(:saving_amount) { 0 }
            it { expect(band_calculation.remission).to eq('part') }
          end

          context "no children married over 66" do
            let(:children_age_band) { nil }
            let(:married) { false }
            let(:fee) { 0 }
            let(:over_66) { true }
            let(:income) { nil }
            let(:saving_amount) { 0 }
            it { expect(band_calculation.remission).to eq('none') }
          end

        end

        context 'age cap over 66' do
          let(:over_66) { true }
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

          context 'part payment with children' do
            let(:children_age_band) { { two: 3 } }
            let(:married) { true }
            let(:fee) { 1750 }
            let(:income) { 5800 }
            let(:saving_amount) { 16000 }
            it {
              expect(band_calculation.remission).to eq('part')
              expect(band_calculation.amount_to_pay).to eq(870)
            }
          end

          context 'part payment single no children' do
            let(:children_age_band) { {} }
            let(:married) { false }
            let(:fee) { 800 }
            let(:income) { 2500 }
            let(:saving_amount) { 15800 }
            it {
              expect(band_calculation.remission).to eq('part')
              expect(band_calculation.amount_to_pay).to eq(550)
            }
          end
        end

        context 'over capital threshold' do
          let(:over_66) { false }
          let(:fee) { 1500 }
          let(:saving_amount) { 10000 }
          it { expect(band_calculation.remission).to eq('none') }
        end

        context 'over capital threshold with no over_66 data' do
          let(:over_66) { nil }
          let(:fee) { 1500 }
          let(:saving_amount) { 10000 }
          it { expect(band_calculation.remission).to eq('none') }
        end

        context 'premiums' do
          let(:saving_amount) { 0 }
          context 'children and married - full' do
            let(:fee) { 1421 }
            let(:income) { 4263 }
            let(:children_age_band) { { one: 1, two: 1 } }
            let(:married) { true }
            it { expect(band_calculation.remission).to eq('full') }
          end
          context 'children and married none - over max income cap' do
            let(:fee) { 1350 }
            let(:income) { 6560 }
            let(:children_age_band) { { two: 2 } }
            let(:married) { true }
            it { expect(band_calculation.remission).to eq('none') }
          end

          context 'children and married - part' do
            let(:fee) { 1350 }
            let(:income) { 5300 }
            let(:children_age_band) { { one: 2, two: 1 } }
            let(:married) { true }
            it {
              expect(band_calculation.remission).to eq('part')
              expect(band_calculation.amount_to_pay).to eq(920)
            }
          end
        end

      end
    end
  end

end
