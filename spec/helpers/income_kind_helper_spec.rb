require 'rails_helper'

RSpec.describe IncomeKindHelper do

  describe '#kind_checked' do
    subject(:kind_checked) { helper.kind_checked(application, claimant, kind) }

    context 'when application has kind' do
      let(:application) { build_stubbed(:application, income_kind: { applicant: ['wage'] }) }
      let(:form) { Forms::Application::IncomeKindApplicant }
      let(:claimant) { :applicant }
      let(:kind) { :wage }

      it { is_expected.to be true }
    end

    context 'when application does not contain kind' do
      let(:application) { build_stubbed(:application, income_kind: { applicant: [] }) }
      let(:form) { Forms::Application::IncomeKindApplicant }
      let(:claimant) { :applicant }
      let(:kind) { 1 }

      it { is_expected.to be false }
    end
  end
end
