require 'spec_helper'

describe User, :type => :model do
  let(:user) do
    User.new({
      email: 'test@email.com',
      password: 'aabbccdd'
    })
  end
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
      user1 = User.create({
                               email: 'test@email.com',
                               password: 'aabbccdd'
                           })

      duplicate = User.new({
                        email: 'test@email.com',
                        password: 'aabbccdd'
                       })
      expect(duplicate).to be_invalid
    end

    it 'should require a minimum 8 character password' do
      user.password = 'aabbcc'
      expect(user).to be_invalid
    end

  end
end
