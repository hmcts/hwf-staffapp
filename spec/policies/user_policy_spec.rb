require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  subject(:policy) { described_class.new(user, subject_user) }

  let(:subject_user) { build_stubbed(:user) }

  def dup_user(user)
    # HACK: how to achieve the same stubbed object in 2 different instances
    user.dup.tap do |new_user|
      new_user.id = user.id
    end
  end

  context 'for staff' do
    let(:user) { build_stubbed(:staff) }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:list_deleted) }
    it { is_expected.not_to permit_action(:destroy) }
    it { is_expected.not_to permit_action(:restore) }
    it { is_expected.not_to permit_action(:invite) }
    it { is_expected.not_to permit_action(:new) }
    it { is_expected.not_to permit_action(:create) }

    describe 'allowed roles' do
      it { expect(policy.allowed_role).to eql(['user']) }
    end

    context 'when the subject_user is the staff themselves' do
      let(:subject_user) { dup_user(user) }

      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:edit_password) }
      it { is_expected.to permit_action(:update_password) }
      it { is_expected.to permit_action(:edit_office) }
      it { is_expected.to permit_action(:edit_jurisdiction) }

      context 'when the role is staff' do
        before do
          subject_user.role = 'user'
        end

        it { is_expected.to permit_action(:update) }
      end

      ['manager', 'admin', 'mi', 'reader'].each do |role|
        context "when trying to set a role to #{role}" do
          before do
            subject_user.role = role
          end

          it { is_expected.not_to permit_action(:update) }
        end
      end
    end

    context 'when the subject_user is not the staff themselves' do
      it { is_expected.not_to permit_action(:show) }
      it { is_expected.not_to permit_action(:edit) }
      it { is_expected.not_to permit_action(:update) }
      it { is_expected.not_to permit_action(:edit_password) }
      it { is_expected.not_to permit_action(:update_password) }
      it { is_expected.not_to permit_action(:edit_office) }
      it { is_expected.not_to permit_action(:edit_jurisdiction) }

    end
  end

  context 'for manager' do
    let(:office) { build_stubbed(:office) }
    let(:user) { build_stubbed(:manager, office: office) }

    describe 'allowed roles' do
      it { expect(policy.allowed_role).to eql(['user', 'manager', 'reader']) }
    end

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.not_to permit_action(:list_deleted) }
    it { is_expected.not_to permit_action(:restore) }
    it { is_expected.not_to permit_action(:invite) }

    context 'when the subject_user belongs to the same office as the manager' do
      let(:subject_user) { build_stubbed(:user, office: office) }

      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:edit) }

      context 'when the subject_user is the manager themselves' do
        let(:subject_user) { dup_user(user) }

        it { is_expected.not_to permit_action(:destroy) }
        it { is_expected.to permit_action(:edit_password) }
        it { is_expected.to permit_action(:update_password) }
        it { is_expected.to permit_action(:edit_office) }
        it { is_expected.to permit_action(:edit_jurisdiction) }

        context 'when trying to set a role to admin' do
          before do
            subject_user.role = :admin
          end

          it { is_expected.not_to permit_action(:update) }
        end
      end

      context 'when the subject_user is not the manager themselves' do
        it { is_expected.to permit_action(:destroy) }
        it { is_expected.not_to permit_action(:edit_password) }
        it { is_expected.not_to permit_action(:update_password) }
        it { is_expected.to permit_action(:edit_office) }
        it { is_expected.to permit_action(:edit_jurisdiction) }

        ['user', 'manager', 'reader'].each do |role|
          context "when role set to #{role}" do
            let(:subject_user) { build_stubbed(:user, office: office, role: role) }

            it { is_expected.to permit_action(:create) }
            it { is_expected.to permit_action(:update) }
          end
        end

        ['admin', 'mi'].each do |role|
          context "when role set to #{role}" do
            let(:subject_user) { build_stubbed(:user, office: office, role: role) }

            it { is_expected.not_to permit_action(:create) }
            it { is_expected.not_to permit_action(:update) }
          end
        end
      end
    end

    context 'when the subject_user does not belong to the same office as the manager' do
      it { is_expected.not_to permit_action(:show) }
      it { is_expected.not_to permit_action(:create) }
      it { is_expected.not_to permit_action(:edit) }
      it { is_expected.not_to permit_action(:destroy) }
      it { is_expected.to permit_action(:edit_office) }
      it { is_expected.to permit_action(:edit_jurisdiction) }

      ['admin', 'mi'].each do |role|
        context "when trying to set a role to #{role}" do
          before do
            subject_user.role = role
          end

          it { is_expected.not_to permit_action(:update) }
        end
      end
    end
  end

  context 'for admin' do
    let(:user) { build_stubbed(:admin) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:list_deleted) }
    it { is_expected.to permit_action(:restore) }
    it { is_expected.to permit_action(:invite) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:edit_office) }
    it { is_expected.to permit_action(:edit_jurisdiction) }

    describe 'allowed roles' do
      it { expect(policy.allowed_role).to eql(['user', 'manager', 'admin', 'mi', 'reader']) }
    end

    context 'when the subject_user is the admin themselves' do
      let(:subject_user) { dup_user(user) }

      it { is_expected.not_to permit_action(:destroy) }
      it { is_expected.to permit_action(:edit_password) }
      it { is_expected.to permit_action(:update_password) }
    end

    context 'when the subject_user is not the admin themselves' do
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.not_to permit_action(:edit_password) }
      it { is_expected.not_to permit_action(:update_password) }
    end
  end

  context 'for mi' do
    let(:user) { build_stubbed(:mi) }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:list_deleted) }
    it { is_expected.not_to permit_action(:destroy) }
    it { is_expected.not_to permit_action(:restore) }
    it { is_expected.not_to permit_action(:invite) }
    it { is_expected.not_to permit_action(:new) }
    it { is_expected.not_to permit_action(:create) }
    it { is_expected.not_to permit_action(:edit_office) }
    it { is_expected.not_to permit_action(:edit_jurisdiction) }

    describe 'allowed roles' do
      it { expect(policy.allowed_role).to eql(['mi']) }
    end

    context 'when the subject_user is the mi themselves' do
      let(:subject_user) { dup_user(user) }

      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:edit_password) }
      it { is_expected.to permit_action(:update_password) }
      it { is_expected.to permit_action(:edit_office) }
      it { is_expected.to permit_action(:edit_jurisdiction) }

      context 'when the role is mi' do
        before do
          subject_user.role = 'mi'
        end

        it { is_expected.to permit_action(:update) }
      end

      ['user', 'manager', 'admin'].each do |role|
        context "when trying to set a role to #{role}" do
          before do
            subject_user.role = role
          end

          it { is_expected.not_to permit_action(:update) }
        end
      end
    end

    context 'when the subject_user is not the mi themselves' do
      it { is_expected.not_to permit_action(:show) }
      it { is_expected.not_to permit_action(:edit) }
      it { is_expected.not_to permit_action(:update) }
      it { is_expected.not_to permit_action(:edit_password) }
      it { is_expected.not_to permit_action(:update_password) }
      it { is_expected.not_to permit_action(:edit_office) }
      it { is_expected.not_to permit_action(:edit_jurisdiction) }

    end
  end

  context 'for reader' do
    let(:user) { build_stubbed(:reader) }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:list_deleted) }
    it { is_expected.not_to permit_action(:destroy) }
    it { is_expected.not_to permit_action(:restore) }
    it { is_expected.not_to permit_action(:invite) }
    it { is_expected.not_to permit_action(:new) }
    it { is_expected.not_to permit_action(:create) }
    it { is_expected.not_to permit_action(:edit_office) }
    it { is_expected.not_to permit_action(:edit_jurisdiction) }

    describe 'allowed roles' do
      it { expect(policy.allowed_role).to eql(['reader']) }
    end

    context 'when the subject_user is the reader themselves' do
      let(:subject_user) { dup_user(user) }

      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:edit_password) }
      it { is_expected.to permit_action(:update_password) }
      it { is_expected.not_to permit_action(:edit_office) }
      it { is_expected.not_to permit_action(:edit_jurisdiction) }

      context 'when the role is reader' do
        before do
          subject_user.role = 'reader'
        end

        it { is_expected.to permit_action(:update) }
      end

      ['manager', 'admin', 'mi', 'user'].each do |role|
        context "when trying to set a role to #{role}" do
          before do
            subject_user.role = role
          end

          it { is_expected.not_to permit_action(:update) }
        end
      end
    end

    context 'when the subject_user is not the reader themselves' do
      it { is_expected.not_to permit_action(:show) }
      it { is_expected.not_to permit_action(:edit) }
      it { is_expected.not_to permit_action(:update) }
      it { is_expected.not_to permit_action(:edit_password) }
      it { is_expected.not_to permit_action(:update_password) }
      it { is_expected.not_to permit_action(:edit_office) }
      it { is_expected.not_to permit_action(:edit_jurisdiction) }
    end
  end

  describe described_class::Scope do
    describe '#resolve' do
      subject(:resolve) { described_class.new(user, User).resolve }

      let(:office) { create :office }
      let(:other_office) { create :office }

      let!(:user1) { create :user, office: office }
      let!(:user2) { create :manager, office: office }
      let!(:user3) { create :admin, office: office }
      let!(:user4) { create :user, office: other_office }
      let!(:user5) { create :manager, office: other_office }
      let!(:user6) { create :admin, office: other_office }

      context 'for staff' do
        let(:user) { create(:staff, office: office) }

        it { is_expected.to be_empty }
      end

      context 'for manager' do
        let(:user) { create(:manager, office: office) }

        it 'returns only users and managers from the same office' do
          is_expected.to match_array([user, user1, user2])
        end
      end

      context 'for admin' do
        let(:user) { create(:admin, office: office) }

        it 'returns all users' do
          is_expected.to match_array([user, user1, user2, user3, user4, user5, user6])
        end
      end

      context 'for an mi' do
        let(:user) { create(:mi, office: office) }

        it 'returns an empty collection' do
          is_expected.to be_empty
        end
      end
    end
  end
end
