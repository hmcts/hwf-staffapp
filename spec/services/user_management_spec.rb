require 'rails_helper'

RSpec.describe UserManagement do
  let(:check) { described_class.new(current_user, staff_member) }
  let(:current_user) { create :admin_user }

  describe '#deletion_permitted?' do
    let(:staff_member) { create :user }

    context 'the current user is elevated' do
      context 'the current_user is not the staff member' do
        it { expect(check.deletion_permitted?).to be true }
      end

      context 'the current_user is the staff member' do
        let(:check) { described_class.new(current_user, current_user) }

        it { expect(check.deletion_permitted?).to be false }
      end
    end

    context 'the current user is not an elevated user' do
      let(:current_user) { create :user }
      it { expect(check.deletion_permitted?).to be false }
    end
  end

  describe '#user_themselves?' do
    context 'the current_user is not the staff member' do
      let(:staff_member) { create :user }
      it { expect(check.user_themselves?).to be false }
    end
    context 'the current_user is the staff member' do
      let(:check) { described_class.new(current_user, current_user) }

      it { expect(check.user_themselves?).to be true }
    end
  end

  describe '#transferred?' do
    context 'current_user is a manager' do
      let(:current_user) { create :manager }

      context 'user is in a different office' do
        let(:staff_member) { create :user }

        it { expect(check.transferred?).to be true }
      end

      context 'user is in the same office as current_user' do
        let(:staff_member) { create :user, office: current_user.office }

        it { expect(check.transferred?).to be false }
      end
    end

  end

  describe '#admin_manager_or_user_themselves?' do
    let(:check) { described_class.new(current_user, nil) }

    context 'current_user is admin' do
      let(:current_user) { create :admin_user }

      it { expect(check.admin_manager_or_user_themselves?).to be true }
    end

    context 'current_user is manager' do
      let(:current_user) { create :manager }
      let(:staff_member) { create :user, office: current_user.office }
      let(:check) { described_class.new(current_user, current_user) }

      it { expect(check.admin_manager_or_user_themselves?).to be true }
    end

    context 'current_user is staff member ' do
      let(:current_user) { create :user }
      let(:check) { described_class.new(current_user, current_user) }

      it { expect(check.admin_manager_or_user_themselves?).to be true }
    end

  end

  describe '#manager_cant_escalate_to_admin?' do
    context 'current_user is a manager' do
      let(:current_user) { create :manager }

      context 'and manages the staff member' do
        let(:staff_member) { create :user, office: current_user.office }

        context 'and submits manager as a role' do
          it { expect(check.manager_cant_escalate_to_admin?('manager')).to be true }
        end
      end
    end
  end
end
