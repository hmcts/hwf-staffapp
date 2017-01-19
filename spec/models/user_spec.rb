# coding: utf-8
require 'rails_helper'

describe User, type: :model do

  let(:user)          { build :user }
  let(:manager)       { build :manager }
  let(:admin_user)    { build :admin_user }
  let(:mi)            { build :mi }

  it 'pass factory build' do
    expect(user).to be_valid
  end

  describe 'scopes' do
    describe 'by_office' do
      let(:office1) { create(:office) }
      let(:office2) { create(:office) }

      before do
        described_class.delete_all
        create(:user, office: office1)
        create_list :user, 3, office: office2
      end

      describe 'filters users by office' do
        it { expect(described_class.by_office(office1).count).to eq 1 }
        it { expect(described_class.by_office(office2).count).to eq 3 }
      end
    end
  end

  describe 'responds to' do
    it 'jurisdiction' do
      expect(user).to respond_to :jurisdiction
    end
  end

  describe 'validations' do
    context 'email' do
      it 'require an email' do
        user.email = nil
        expect(user).to be_invalid
      end

      it 'require a valid email' do
        user.email = 'testemail'
        expect(user).to be_invalid
      end

      it 'require a unique email' do
        original = create(:user)
        duplicate = build(:user)
        duplicate.email = original.email
        expect(duplicate).to be_invalid
      end

      context '(hmcts.gsi|digital.justice).gov.uk email addresses' do
        let(:user) { build(:user) }

        it 'requires only whitelisted email addresses' do
          expect(user).to be_valid
        end

        it 'allows hmcourts-service emails' do
          user.email = 'test.user@hmcourts-service.gsi.gov.uk'
          expect(user).to be_valid
        end

        it 'allows hmcts.net' do
          user.email = 'test.user@hmcts.net'
          expect(user).to be_valid
        end

        context 'non white listed emails' do
          let(:invalid_email) { 'email.that.rocks@gmail.com' }
          before { user.email = invalid_email }
          error_message = I18n.t('activerecord.errors.models.user.attributes.email.invalid_email', email: Settings.mail.tech_support)

          it 'will not accept non white listed emails' do
            expect(user).to be_invalid
          end

          it 'has an informative error message for non white listed emails' do
            user.valid?
            expect(user.errors.messages[:email].first).to match error_message
          end
        end
      end
    end

    it 'requires a name' do
      user.name = nil
      expect(user).to be_invalid
    end

    it 'require a minimum 8 character password' do
      user.password = 'aabbcc'
      expect(user).to be_invalid
    end

    describe 'require a non-nil role' do
      before do
        user.role = nil
        user.valid?
      end

      it { expect(user).to be_invalid }
      it { expect(user.errors[:role]).to eq ["can't be blank"] }
    end

    describe 'require a valid role' do
      before do
        user.role = 'student'
        user.valid?
      end

      it { expect(user).to be_invalid }
      it { expect(user.errors[:role]).to eq ["student is not a valid role"] }
    end

    describe 'jurisdiction' do
      describe 'must be valid' do
        before do
          user.jurisdiction_id = -999
          user.valid?
        end

        it { expect(user).to be_invalid }
        it { expect(user.errors[:jurisdiction]).to eq ["Jurisdiction must exist"] }
      end

      it 'may be nil' do
        user.jurisdiction = nil
        expect(user).to be_valid
      end
    end
  end

  describe '@elevated?' do
    it 'respond true if manager user' do
      expect(manager.elevated?).to be true
    end

    it 'respond true if admin user' do
      expect(admin_user.elevated?).to be true
    end

    it 'respond false if  user' do
      expect(user.elevated?).to be false
    end
  end

  describe '#staff?' do
    it 'respond false for staff' do
      expect(user.staff?).to be true
    end

    it 'respond false if mi' do
      expect(mi.staff?).to be false
    end

    it 'respond false for manager' do
      expect(manager.staff?).to be false
    end

    it 'respond false for admin' do
      expect(admin_user.staff?).to be false
    end
  end

  describe '@manager?' do
    it 'respond true if manager user' do
      expect(manager.manager?).to be true
    end

    it 'respond false if mi' do
      expect(mi.manager?).to be false
    end

    it 'respond false if admin user' do
      expect(admin_user.manager?).to be false
    end

    it 'respond false if  user' do
      expect(user.manager?).to be false
    end
  end

  describe '@admin?' do
    it 'respond true if admin user' do
      expect(admin_user.admin?).to be true
    end

    it 'respond false if mi' do
      expect(mi.admin?).to be false
    end

    it 'respond false if manager' do
      expect(manager.admin?).to be false
    end

    it 'respond false if user' do
      expect(user.admin?).to be false
    end
  end

  describe '#mi?' do
    it 'respond true if mi user' do
      expect(mi.mi?).to be true
    end

    it 'respond false if admin' do
      expect(admin_user.mi?).to be false
    end

    it 'respond false if manager' do
      expect(manager.admin?).to be false
    end

    it 'respond false if user' do
      expect(user.admin?).to be false
    end
  end

  describe 'soft deletion' do
    before { [admin_user, mi, manager, user].map(&:save) }

    context 'to start off' do
      it 'will have 3 users' do
        expect(described_class.count).to eq 4
      end
    end

    context 'when soft deleted' do
      before { user.destroy }

      it 'removes the user from the default scope' do
        expect(described_class.count).to eq 3
      end

      it 'throws an error when using the default scope' do
        expect { described_class.find(user.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'still keeps the user information around' do
        expect(described_class.with_deleted.find(user.id)).to eq user
      end
    end
  end
end
