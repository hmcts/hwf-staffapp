# coding: utf-8
require 'rails_helper'

RSpec.describe Views::Overview::Income do

  let(:application) { build_stubbed(:application) }
  subject(:view) { described_class.new(application) }

  describe '#all_fields' do
    subject { view.all_fields }

    it { is_expected.to eql %w[children? children income] }
  end

  describe '#children??' do
    let(:application) { build_stubbed :application, dependents: dependents }
    subject { view.children? }

    [true, false].each do |value|
      context "when dependents is #{value}" do
        let(:dependents) { value }

        it { is_expected.to eq I18n.t("convert_boolean.#{value}") }
      end
    end
  end

  describe '#children' do
    let(:application) { build_stubbed :application, dependents: dependents, children: children }
    subject { view.children }

    context 'when the applicant has dependants' do
      let(:dependents) { true }

      context 'and children is above 0' do
        let(:children) { 2 }

        it { is_expected.to eq 2 }
      end
    end

    context 'when the applicant no dependants' do
      let(:dependents) { false }

      context 'children = 0' do
        let(:children) { 0 }

        it { is_expected.to eq 0 }
      end

      context 'children = 2' do
        let(:children) { 2 }

        it { is_expected.to eq 0 }
      end
    end
  end

  describe '#income' do
    let(:application) { build_stubbed :application, income: 300 }
    subject { view.income }

    it { is_expected.to eq '£300' }
  end
end
