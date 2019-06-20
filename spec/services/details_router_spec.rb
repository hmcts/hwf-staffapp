require 'rails_helper'

describe DetailsRouter do
  include Rails.application.routes.url_helpers

  let(:details) { build_stubbed(:complete_detail) }
  let(:application) { build_stubbed(:application, detail: details) }
  let(:router) { described_class.new(application) }

  describe '#approval_or_continue' do
    subject { router.approval_or_continue }

    let(:details) { build_stubbed(:complete_detail, fee: fee) }

    context 'when fee needs approval' do
      let(:fee) { Settings.fee_approval_threshold }

      it { is_expected.to eql application_approve_path(application) }
    end

    context 'when fee does not needs approval' do
      let(:fee) { 1000 }

      it 'calls #savings_or_summary' do
        allow(router).to receive(:savings_or_summary)

        router.approval_or_continue
        expect(router).to have_received(:savings_or_summary)
      end
    end
  end

  describe '#savings_or_summary' do
    subject { router.savings_or_summary }

    let(:details) { build_stubbed(:complete_detail, discretion_applied: discretion_applied) }

    context 'when discretion has been applied' do
      let(:discretion_applied) { true }

      it { is_expected.to eql application_savings_investments_path(application) }
    end

    context 'when discretion has not been applied' do
      let(:discretion_applied) { false }

      it { is_expected.to eql application_summary_path(application) }
    end
  end
end
