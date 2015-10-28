require 'rails_helper'

RSpec.describe Views::Applikation::Result do
  let(:application) { build_stubbed(:application) }
  subject(:view) { described_class.new(application) }

  let(:string_passed) { '✓ Passed' }
  let(:string_failed) { '✗ Failed' }

  it 'inherits features of Views::ApplicationResult' do
    expect(view).to be_a(Views::ApplicationResult)
  end

  describe '#result' do
    subject { view.result }

    context 'when an application has an evidence_check' do
      before { allow(application).to receive(:evidence_check?).and_return(true) }

      it { is_expected.to eql 'callout' }
    end

    context 'when an application has had benefits overridden' do
      let!(:benefit_override) { build_stubbed :benefit_override, application: application, correct: evidence_correct }

      context 'and the correct evidence was provided' do
        let(:evidence_correct) { true }

        it { is_expected.to eql 'full' }
      end
    end

    context 'when application_outcome is nil' do
      before { application.application_outcome = nil }

      it { is_expected.to eql 'none' }
    end
  end
end
