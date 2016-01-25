require 'rails_helper'

RSpec.describe EvidenceCheckPolicy, type: :policy do
  let(:office) { build_stubbed(:office) }
  let(:application) { build_stubbed(:application, office: office) }
  let(:evidence_check) { build_stubbed(:evidence_check, application: application) }

  subject(:policy) { described_class.new(user, evidence_check) }

  context 'for staff' do
    let(:user) { build_stubbed(:user) }

    context 'when the application belongs to their office' do
      let(:user) { build_stubbed(:user, office: office) }

      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:update) }
    end

    context 'when the application does not belong to their office' do
      it { is_expected.not_to permit_action(:show) }
      it { is_expected.not_to permit_action(:update) }
    end
  end

  context 'for manager' do
    let(:user) { build_stubbed(:manager) }

    context 'when the application belongs to their office' do
      let(:user) { build_stubbed(:manager, office: office) }

      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:update) }
    end

    context 'when the application does not belong to their office' do
      it { is_expected.not_to permit_action(:show) }
      it { is_expected.not_to permit_action(:update) }
    end
  end

  context 'for an admin' do
    let(:user) { build_stubbed(:admin_user) }

    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:update) }
  end

  context 'for an mi' do
    let(:user) { build_stubbed(:mi) }

    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:update) }
  end
end
