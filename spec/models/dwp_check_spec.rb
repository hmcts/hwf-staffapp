require 'rails_helper'

RSpec.describe DwpCheck, type: :model do

  let(:check)      { FactoryGirl.build :dwp_check }

  it 'should pass factory build' do
    expect(check).to be_valid
  end

  context 'validations' do
    it 'should require a last name' do
      check.last_name = nil
      expect(check).to be_invalid
    end
    it 'should require a date of birth' do
      check.dob = nil
      expect(check).to be_invalid
    end
    it 'should require a NI number' do
      check.ni_number = nil
      expect(check).to be_invalid
    end

    it 'should allow a date to check to be passed' do
      check.date_to_check = Date.today
      expect(check).to be_valid
    end

    it 'should only allow valid NI numbers' do
      check.ni_number = 'wrong'
      expect(check).to be_invalid
    end

    it 'should allow a unique number to be set' do
      test_unique = FactoryGirl.create :dwp_check
      expect(test_unique.unique_number).to_not be_nil
      expect(test_unique.unique_number).to match(/[0-9a-fA-F]{4}[-][0-9a-fA-F]{4}/)
      expect(test_unique).to be_valid
    end
  end
end
