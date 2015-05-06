# coding: utf-8
require 'rails_helper'

describe User, type: :model do

  let(:user)          { FactoryGirl.build :user }
  let(:admin_user)    { FactoryGirl.build :admin_user }

  it 'pass factory build' do
    expect(user).to be_valid
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
        original = FactoryGirl.create(:user)
        duplicate = FactoryGirl.build(:user)
        duplicate.email = original.email
        expect(duplicate).to be_invalid
      end

      context '(hmcts.gsi|digital.justice).gov.uk email addresses' do
        let(:user) { FactoryGirl.build(:user) }

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
            expect(user.errors.messages[:email].first).to match I18n.t('activerecord.errors.models.user.attributes.email.invalid')
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
  end

  describe '@admin?' do
    it 'resond true if admin user' do
      expect(admin_user.admin?).to be true
    end

    it 'respond false if not admin user' do
      expect(user.admin?).to be false
    end
  end
end
