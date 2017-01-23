require 'rails_helper'

RSpec.describe ManagerSetup, type: :service do
  subject(:manager_setup) { described_class.new(user, session) }

  let(:session_key) { described_class::SESSION_KEY }
  let(:user) { double }
  let(:session) { {} }

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

        it { is_expected.to be false }
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

  describe '#setup_profile?' do
    subject { manager_setup.setup_profile? }

    context 'for a manager' do
      context 'when the manager signs in for the first time' do
        let(:user) { create :manager, sign_in_count: 1 }

        it { is_expected.to be true }
      end

      context 'when the manager does not sign for the first time' do
        let(:user) { create :manager, sign_in_count: 2 }

        it { is_expected.to be false }
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

  describe '#start!' do
    before { manager_setup.start! }

    it 'stores flag on the session' do
      expect(session[session_key]).to be true
    end
  end

  describe '#in_progress?' do
    subject { manager_setup.in_progress? }

    context 'when the setup was started' do
      before do
        manager_setup.start!
      end

      it { is_expected.to be true }
    end

    context 'when the setup was not started' do
      it { is_expected.to be false }
    end
  end

  describe 'finish!' do
    before do
      session[session_key] = true
    end

    it 'removes the flag from the session' do
      manager_setup.finish!

      expect(session).not_to have_key(session_key)
    end
  end
end
