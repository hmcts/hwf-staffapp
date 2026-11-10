require 'rails_helper'

RSpec.describe HmrcWarningPolicy, type: :policy do
  subject(:policy) { described_class.new(user, hmrc_warning) }

  let(:hmrc_warning) { build_stubbed(:hmrc_warning) }

  [:staff, :manager, :mi, :reader].each do |user_type|
    context "for #{user_type}" do
      let(:user) { build_stubbed(user_type) }

      it { is_expected.not_to permit_action(:edit) }
      it { is_expected.not_to permit_action(:update) }
    end
  end

  context 'for admin' do
    let(:user) { build_stubbed(:admin) }

    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
  end
end
