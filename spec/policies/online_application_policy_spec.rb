require 'rails_helper'

RSpec.describe OnlineApplicationPolicy, type: :policy do
  let(:online_application) { build_stubbed(:online_application) }

  subject(:policy) { described_class.new(user, online_application) }

  context 'for staff' do
    let(:user) { build_stubbed(:staff) }

    it { is_expected.to permit_action(:edit) }
  end

  context 'for manager' do
    let(:user) { build_stubbed(:manager) }

    it { is_expected.to permit_action(:edit) }
  end

  context 'for admin' do
    let(:user) { build_stubbed(:admin) }

    it { is_expected.not_to permit_action(:edit) }
  end
end
