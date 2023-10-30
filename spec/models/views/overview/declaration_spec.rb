require 'rails_helper'

RSpec.describe Views::Overview::Declaration do
  subject(:view) { described_class.new(application) }

  let(:application) { build_stubbed(:application, detail: detail) }
  let(:detail) { build_stubbed(:detail, statement_signed_by: signed_by) }
  let(:signed_by) { nil }

  describe '#all_fields' do
    subject { view.all_fields }

    it do
      is_expected.to eql(['statement_signed_by'])
    end
  end

  describe '#statement_signed_by' do
    subject { view.statement_signed_by }

    context 'blank' do
      it { is_expected.to eq '' }
    end

    context 'applicant' do
      let(:signed_by) { 'applicant' }

      it { is_expected.to eq 'Applicant' }
    end

    context 'litigation_friend' do
      let(:signed_by) { 'litigation_friend' }

      it { is_expected.to eq 'Litigation friend' }
    end

    context 'legal_representative' do
      let(:signed_by) { 'legal_representative' }

      it { is_expected.to eq 'Legal representative' }
    end
  end
end
