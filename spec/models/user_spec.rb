require 'spec_helper'

describe User, :type => :model do

  let(:user)          { FactoryGirl.build :user }
  let(:admin_user)    { FactoryGirl.build :admin_user }

  it 'should pass factory build' do
    expect(user).to be_valid
  end

  describe 'validations' do
    it 'should require an email' do
      user.email = nil
      expect(user).to be_invalid
    end

    it 'should require a valid email' do
      user.email = 'testemail'
      expect(user).to be_invalid
    end

    it 'should require a unique email' do
      original = FactoryGirl.create(:user)
      duplicate = FactoryGirl.build(:user)
      duplicate.email = original.email
      expect(duplicate).to be_invalid
    end

    it 'should require a minimum 8 character password' do
      user.password = 'aabbcc'
      expect(user).to be_invalid
    end

    it 'should require a non-nil role' do
      user.role = nil
      expect(user).to be_invalid
      expect(user.errors[:role]).to eq ["can't be blank"]
    end

    it 'should require a valid role' do
      user.role = 'student'
      expect(user).to be_invalid
      expect(user.errors[:role]).to eq ["student is not a valid role"]
    end
  end

  describe '@admin?' do
    it 'should resond true if admin user' do
      expect(admin_user.admin?).to be true
    end

    it 'should respond false if not admin user' do
      expect(user.admin?).to be false
    end
  end
end
