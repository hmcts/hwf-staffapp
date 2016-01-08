require 'rails_helper'

RSpec.describe ReportPolicy, type: :policy do
  let(:report) { double }

  subject(:policy) { described_class.new(user, report) }

  context 'for staff' do
    let(:user) { build_stubbed(:staff) }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:graphs) }
  end

  context 'for manager' do
    let(:user) { build_stubbed(:manager) }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:graphs) }
  end

  context 'for admin' do
    let(:user) { build_stubbed(:admin) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:graphs) }
  end
end
