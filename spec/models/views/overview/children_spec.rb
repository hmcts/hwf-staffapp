require 'rails_helper'

RSpec.describe Views::Overview::Children do
  subject(:view) { described_class.new(application) }

  let(:application) { build_stubbed(:application) }

  describe '#all_fields' do
    subject { view.all_fields }

    it { is_expected.to eql ['dependents', 'children_age_band'] }
  end

  describe '#dependents' do
    subject { view.dependents }

    let(:application) { build_stubbed(:application, dependents: dependents) }

    [true, false].each do |value|
      context "when dependents is #{value}" do
        let(:dependents) { value }

        it { is_expected.to eq I18n.t("convert_boolean.#{value}") }
      end
    end
  end

  describe '#children_age_band' do
    subject { view.children_age_band }

    let(:application) { build_stubbed(:application, dependents: dependents, children_age_band: age_band) }

    context 'when the age band is blank' do
      let(:dependents) { true }
      let(:age_band) { nil }

      it { is_expected.to be_nil }
    end

    context 'when the age band has just one value' do
      let(:dependents) { true }
      let(:age_band) { { one: 1 } }

      it {
        is_expected.to include("1 (aged 0-13)")
        is_expected.to include("0 (aged 14+)")
      }
    end

    context 'when the age band has both values value' do
      let(:dependents) { true }
      let(:age_band) { { one: 1, two: 2 } }

      it {
        is_expected.to include("1 (aged 0-13)")
        is_expected.to include("2 (aged 14+)")
      }
    end

    context 'when the age band has both wrong keys' do
      let(:dependents) { true }
      let(:age_band) { { on: 1, to: 2 } }

      it { is_expected.to be_nil }
    end

  end

end
