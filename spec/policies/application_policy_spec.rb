require 'rails_helper'

RSpec.describe ApplicationPolicy, type: :policy do
  let(:office) { build_stubbed(:office) }
  let(:application) { build_stubbed(:application, office: office) }

  subject(:policy) { described_class.new(user, application) }

  context 'for staff' do
    let(:user) { build_stubbed(:user) }

    it { is_expected.to permit_action(:index) }

    context 'when the application belongs to their office' do
      let(:user) { build_stubbed(:user, office: office) }

      it { is_expected.to permit_action(:show) }
    end

    context 'when the application does not belong to their office' do
      it { is_expected.not_to permit_action(:show) }
    end
  end

  context 'for a manager' do
    let(:user) { build_stubbed(:manager) }

    it { is_expected.to permit_action(:index) }

    context 'when the application belongs to their office' do
      let(:user) { build_stubbed(:manager, office: office) }

      it { is_expected.to permit_action(:show) }
    end

    context 'when the application does not belong to their office' do
      it { is_expected.not_to permit_action(:show) }
    end
  end

  context 'for an admin' do
    let(:user) { build_stubbed(:admin_user) }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:show) }
  end
end
