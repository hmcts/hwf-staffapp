require 'rails_helper'

describe CompletedApplicationRedirect do
  include Rails.application.routes.url_helpers

  let(:user) { create :user }
  let(:service) { described_class.new(application) }

  subject { service.path }

  describe 'when initialised with a processed application' do
    let(:application) { create :application, :processed_state, office: user.office }

    it { is_expected.to eql processed_application_path(application) }
  end

  describe 'when initialised with an application awaiting part_payment' do
    let(:application) { create :application, :waiting_for_part_payment_state, office: user.office }
    let!(:part_payment) { create(:part_payment, application: application) }

    it { is_expected.to eql part_payment_path(part_payment) }
  end

  describe 'when initialised with an application awaiting evidence' do
    let(:application) { create :application, :waiting_for_evidence_state, office: user.office }
    let!(:evidence) { create :evidence_check, application: application }

    it { is_expected.to eql evidence_show_path(evidence) }
  end

  describe 'when initialised with a deleted application' do
    let(:application) { create :application, :deleted_state, office: user.office }

    it { is_expected.to eql deleted_application_path(application) }
  end
end
