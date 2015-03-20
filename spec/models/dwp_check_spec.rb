require 'rails_helper'

RSpec.describe DwpCheck, type: :model do

  let(:check)      { FactoryGirl.build :dwp_check }

  it 'pass factory build' do
    expect(check).to be_valid
  end

  context 'validations' do
    it 'require a last name' do
      check.last_name = nil
      expect(check).to be_invalid
    end

    it 'requires last name to be at least 2 characters' do
      check.last_name = 'a'
      expect(check).to be_invalid
      expect(check.errors[:last_name]).to eq ['is too short (minimum is 2 characters)']
    end

    it 'require a date of birth' do
      check.dob = nil
      expect(check).to be_invalid
    end
    it 'require a NI number' do
      check.ni_number = nil
      expect(check).to be_invalid
    end

    it 'allow a date to check to be passed' do
      check.date_to_check = Date.today
      expect(check).to be_valid
    end

    it 'only allow valid NI numbers' do
      check.ni_number = 'wrong'
      expect(check).to be_invalid
    end

    it 'allow a unique number to be set' do
      test_unique = FactoryGirl.create :dwp_check
      expect(test_unique.unique_number).to_not be_nil
      expect(test_unique.unique_number).to match(/[0-9a-fA-F]{4}[-][0-9a-fA-F]{4}/)
      expect(test_unique).to be_valid
    end

    it 'allow the created_by_id to be set' do
      user = FactoryGirl.create :user
      dwp = FactoryGirl.build :dwp_check
      dwp.created_by_id = user.id
      expect(dwp.created_by_id).to_not be_nil
      expect(dwp.created_by.email).to eql(user.email)
      expect(dwp).to be_valid
    end
  end
end
