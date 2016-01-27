require 'rails_helper'

RSpec.describe BenefitOverridePolicy, type: :policy do
  let(:office) { build_stubbed(:office) }
  let(:application) { build_stubbed(:application, office: office) }
  let(:benefit_override) { build_stubbed(:benefit_override, application: application) }

  subject(:policy) { described_class.new(user, benefit_override) }

  context 'for staff' do
    let(:user) { build_stubbed(:user) }

    context 'when the application belongs to their office' do
      let(:user) { build_stubbed(:user, office: office) }

      it { is_expected.to permit_action(:create) }
    end

    context 'when the application does not belong to their office' do
      it { is_expected.not_to permit_action(:create) }
    end
  end

  context 'for manager' do
    let(:user) { build_stubbed(:manager) }

    context 'when the application belongs to their office' do
      let(:user) { build_stubbed(:manager, office: office) }

      it { is_expected.to permit_action(:create) }
    end

    context 'when the application does not belong to their office' do
      it { is_expected.not_to permit_action(:create) }
    end
  end

  context 'for an admin' do
    let(:user) { build_stubbed(:admin_user) }

    it { is_expected.not_to permit_action(:create) }
  end

  context 'for an mi' do
    let(:user) { build_stubbed(:mi) }

    it { is_expected.not_to permit_action(:create) }
  end
end
