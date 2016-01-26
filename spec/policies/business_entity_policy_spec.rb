require 'rails_helper'

RSpec.describe BusinessEntityPolicy, type: :policy do
  let(:office) { build_stubbed(:office) }

  subject(:policy) { described_class.new(user, office) }

  context 'for staff' do
    let(:user) { build_stubbed(:staff) }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:edit) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:new) }
    it { is_expected.not_to permit_action(:create) }
    it { is_expected.not_to permit_action(:deactivate) }
    it { is_expected.not_to permit_action(:confirm_deactivate) }
  end

  context 'for manager' do
    let(:user) { build_stubbed(:manager) }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:edit) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:new) }
    it { is_expected.not_to permit_action(:create) }
    it { is_expected.not_to permit_action(:deactivate) }
    it { is_expected.not_to permit_action(:confirm_deactivate) }
  end

  context 'for admin' do
    let(:user) { build_stubbed(:admin) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:deactivate) }
    it { is_expected.to permit_action(:confirm_deactivate) }
  end
end
