require 'rails_helper'

RSpec.describe R2Calculator, type: :model do

  let(:r2_calc) { FactoryGirl.build :r2_calculator }

  it 'passes factory build' do
    expect(r2_calc).to be_valid
  end
  context 'validations' do
    it 'requires a fee' do
      r2_calc.fee = nil
      expect(r2_calc).to be_invalid
    end
    it 'requires a positive fee' do
      r2_calc.fee = -1
      expect(r2_calc).to be_invalid
    end
    it 'requires a marital_status' do
      r2_calc.married = nil
      expect(r2_calc).to be_invalid
    end
    it 'requires a child count' do
      r2_calc.children = nil
      expect(r2_calc).to be_invalid
    end
    it 'requires a positive child count' do
      r2_calc.children = -1
      expect(r2_calc).to be_invalid
    end
    it 'requires a income total' do
      r2_calc.income = nil
      expect(r2_calc).to be_invalid
    end
    it 'requires a positive income' do
      r2_calc.income = -1
      expect(r2_calc).to be_invalid
    end
    it 'requires a creator' do
      r2_calc.created_by = nil
      expect(r2_calc).to be_invalid
    end
    it 'requires a remittance amount' do
      r2_calc.remittance = nil
      expect(r2_calc).to be_invalid
    end
    it 'requires a positive remittance amount' do
      r2_calc.remittance = -1
      expect(r2_calc).to be_invalid
    end
    it 'requires a to_pay amount' do
      r2_calc.remittance = nil
      expect(r2_calc).to be_invalid
    end
    it 'requires a positive to_pay amount' do
      r2_calc.remittance = -1
      expect(r2_calc).to be_invalid
    end
    it 'ensures that remittance+to_pay=fee' do
      expect(r2_calc.to_pay + r2_calc.remittance).to eql(r2_calc.fee)
    end
  end
end
