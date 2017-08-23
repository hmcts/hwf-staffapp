require 'rails_helper'

RSpec.describe FeedbackPolicy, type: :policy do
  subject(:policy) { described_class.new(user, feedback) }

  let(:office) { build_stubbed(:office) }
  let(:feedback) { build_stubbed(:feedback) }

  [:staff, :manager].each do |user_type|
    context "for #{user_type}" do
      let(:user) { build_stubbed(user_type, office: office) }

      it { is_expected.not_to permit_action(:index) }
      it { is_expected.to permit_action(:new) }

      context 'for feedback belonging to the user and their office' do
        let(:feedback) { build_stubbed(:feedback, office: office, user: user) }

        it { is_expected.to permit_action(:create) }
      end

      context 'for feedback belonging to the user but different office' do
        let(:feedback) { build_stubbed(:feedback, user: user) }

        it { is_expected.not_to permit_action(:create) }
      end

      context 'for feedback belonging to the office but different user' do
        let(:feedback) { build_stubbed(:feedback, office: office) }

        it { is_expected.not_to permit_action(:create) }
      end
    end
  end

  context 'for admin' do
    let(:user) { build_stubbed(:admin) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.not_to permit_action(:new) }
    it { is_expected.not_to permit_action(:create) }
  end

  context 'for an mi' do
    let(:user) { build_stubbed(:mi) }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:new) }
    it { is_expected.not_to permit_action(:create) }
  end
end
