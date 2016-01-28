require 'rails_helper'

RSpec.describe OfficePolicy, type: :policy do
  let(:office) { build_stubbed(:office) }

  subject(:policy) { described_class.new(user, office) }

  context 'for staff' do
    let(:user) { build_stubbed(:staff) }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:new) }
    it { is_expected.not_to permit_action(:create) }
    it { is_expected.not_to permit_action(:edit) }
    it { is_expected.not_to permit_action(:update) }

    context 'when the user belongs to the office' do
      let(:user) { build_stubbed(:staff, office: office) }

      it { is_expected.to permit_action(:show) }
    end

    context 'when the user does not belong to the office' do
      it { is_expected.not_to permit_action(:show) }
    end
  end

  context 'for manager' do
    let(:user) { build_stubbed(:manager) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }

    it { is_expected.not_to permit_action(:new) }
    it { is_expected.not_to permit_action(:create) }

    context 'when the user belongs to the office' do
      let(:user) { build_stubbed(:manager, office: office) }

      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
    end

    context 'when the user does not belong to the office' do
      it { is_expected.not_to permit_action(:edit) }
      it { is_expected.not_to permit_action(:update) }
    end

  end

  context 'for admin' do
    let(:user) { build_stubbed(:admin) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
  end

  context 'for an mi' do
    let(:user) { build_stubbed(:mi) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.not_to permit_action(:new) }
    it { is_expected.not_to permit_action(:create) }
    it { is_expected.not_to permit_action(:edit) }
    it { is_expected.not_to permit_action(:update) }
  end
end
