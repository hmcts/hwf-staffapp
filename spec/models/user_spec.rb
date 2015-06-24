# coding: utf-8
require 'rails_helper'

describe User, type: :model do

  let(:user)          { build :user }
  let(:manager)       { build :manager }
  let(:admin_user)    { build :admin_user }

  it 'pass factory build' do
    expect(user).to be_valid
  end

  describe 'scopes' do
    describe 'by_office' do
      before { described_class.delete_all }
      it 'filters users by office' do
        office1 = FactoryGirl.create(:office)
        office2 = FactoryGirl.create(:office)
        FactoryGirl.create(:user, office: office1)
        FactoryGirl.create_list :user, 3, office: office2

        expect(described_class.by_office(office1).count).to eql(1)
        expect(described_class.by_office(office2).count).to eql(3)

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

        context 'non white listed emails' do
          let(:invalid_email) { 'email.that.rocks@gmail.com' }
          before(:each) { user.email = invalid_email }

          it 'will not accept non white listed emails' do
            expect(user).to be_invalid
          end

          it 'has an informative error message for non white listed emails' do
            user.valid?
            expect(user.errors.messages[:email].first).to match I18n.t('dictionary.invalid_email', email: Settings.mail_tech_support)
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

    it 'require a non-nil role' do
      user.role = nil
      expect(user).to be_invalid
      expect(user.errors[:role]).to eq ["can't be blank"]
    end

    it 'require a valid role' do
      user.role = 'student'
      expect(user).to be_invalid
      expect(user.errors[:role]).to eq ["student is not a valid role"]
    end

    describe 'jurisdiction' do
      it 'must be valid' do
        user.jurisdiction_id = -999
        expect(user).to be_invalid
        expect(user.errors[:jurisdiction]).to eq ["Jurisdiction must exist"]
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

  describe '@manager?' do
    it 'respond true if manager user' do
      expect(manager.manager?).to be true
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

    it 'respond false if manager' do
      expect(manager.admin?).to be false
    end
    it 'respond false if user' do
      expect(user.admin?).to be false
    end
  end
end
