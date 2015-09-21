require 'rails_helper'

RSpec.describe ManagerSetup, type: :service do
  subject(:manager_setup) { described_class.new(user) }

  describe '#setup_office?' do
    subject { manager_setup.setup_office? }

    context 'for a manager' do
      let(:office) { create :office }

      context 'when the manager signs in for the first time' do
        let(:user) { create :manager, office: office, sign_in_count: 1 }

        it { is_expected.to be true }
      end

      context 'when does not sign for the first time' do
        let(:user) { create :manager, office: office, sign_in_count: 2 }

        context 'when the office has not been setup' do
          it { is_expected.to be true }
        end

        context 'when the office has been setup' do
          let(:office) { create :office_with_jurisdictions }

          it { is_expected.to be false }
        end
      end
    end

    context 'for a standard user' do
      let(:user) { create :user }
      it { is_expected.to be false }
    end

    context 'for an admin user' do
      let(:user) { create :admin_user }

      it { is_expected.to be false }
    end
  end
end
