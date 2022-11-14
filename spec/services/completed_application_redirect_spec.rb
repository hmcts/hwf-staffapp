require 'rails_helper'

describe CompletedApplicationRedirect do
  include Rails.application.routes.url_helpers

  let(:user) { create(:user) }
  let(:service) { described_class.new(application) }

  describe '.path' do
    subject { service.path }

    describe 'when initialised with a processed application' do
      let(:application) { create(:application, :processed_state, office: user.office) }

      it { is_expected.to eql processed_application_path(application) }
    end

    describe 'when initialised with an application awaiting part_payment' do
      let(:application) { create(:application, :waiting_for_part_payment_state, office: user.office) }
      let!(:part_payment) { create(:part_payment, application: application) }

      it { is_expected.to eql part_payment_path(part_payment) }
    end

    describe 'when initialised with an application awaiting evidence' do
      let(:application) { create(:application, :waiting_for_evidence_state, office: user.office) }
      let!(:evidence) { create(:evidence_check, application: application) }

      it { is_expected.to eql evidence_path(evidence) }

      describe 'hmrc evidence check' do
        let(:evidence) { create(:evidence_check, application: application, income_check_type: 'hmrc') }
        let(:hmrc_check) { create(:hmrc_check, evidence_check: evidence, income: income) }
        before { hmrc_check }

        context 'no income' do
          let(:income) { nil }
          it { is_expected.to eql new_evidence_check_hmrc_path(evidence) }
        end

        context 'posivite income' do
          let(:income) { [{ "taxablePay" => 12000.04 }] }
          it { is_expected.to eql evidence_check_hmrc_path(evidence, hmrc_check) }
        end
      end
    end

    describe 'when initialised with a deleted application' do
      let(:application) { create(:application, :deleted_state, office: user.office) }

      it { is_expected.to eql deleted_application_path(application) }
    end
  end

  describe '.flash_message' do
    subject { service.flash_message }

    describe 'when initialised with a processed application' do
      let(:application) { create(:application, :processed_state, office: user.office) }

      it { is_expected.to eql 'This application has been processed. You can’t edit any details.' }
    end

    describe 'when initialised with an application awaiting part_payment' do
      let(:application) { create(:application, :waiting_for_part_payment_state, office: user.office) }
      before { create(:part_payment, application: application) }

      it { is_expected.to eql 'This application is waiting for part-payment. You can’t edit any details.' }
    end

    describe 'when initialised with an application awaiting evidence' do
      let(:application) { create(:application, :waiting_for_evidence_state, office: user.office) }
      before { create(:evidence_check, application: application) }

      it { is_expected.to eql 'This application is waiting for evidence. You can’t edit any details.' }
    end

    describe 'when initialised with a deleted application' do
      let(:application) { create(:application, :deleted_state, office: user.office) }

      it { is_expected.to eql 'This application has been deleted. You can’t edit any details.' }
    end
  end
end
