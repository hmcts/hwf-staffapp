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
  describe 'responds' do
    it 'to type' do
      expect(r2_calc).to respond_to(:type)
    end
  end
  describe 'types' do
    it 'returns none if remittance is zero' do
      r2_calc.remittance = 0
      r2_calc.to_pay = 9.99
      r2_calc.save!
      expect(r2_calc.type).to eql('None')
    end
    it 'returns part if remittance and to_pay have values' do
      r2_calc.remittance = 4.44
      r2_calc.to_pay = 5.55
      r2_calc.save
      expect(r2_calc.type).to eql('Part')
    end
    it 'returns full if to_pay has a value and remittance is zero' do
      r2_calc.remittance = 9.99
      r2_calc.to_pay = 0
      r2_calc.save
      expect(r2_calc.type).to eql('Full')
    end
  end

  describe 'scopes' do
    before(:each) { described_class.delete_all }
    describe 'checks_by_day' do
      let!(:old_check) do
        old = FactoryGirl.create :r2_calculator
        old.update(created_at: "#{Date.today.-8.days}")
      end
      let!(:new_check) do
        check = FactoryGirl.create :r2_calculator
        check.update(created_at: "#{Date.today.-5.days}")
      end

      it 'finds only checks for the past week' do
        expect(described_class.checks_by_day.count).to eq 1
      end
    end

    describe 'by_office_grouped_by_type' do
      let!(:user) do
        user = FactoryGirl.create :user
        user.update(office_id: 1)
        user
      end
      let!(:calc) do
        calc = FactoryGirl.create(:r2_calculator)
        calc.update(created_by_id: user.id)
      end
      let!(:full_calc) do
        calc = FactoryGirl.create(:r2_calculator, remittance: 9.99, to_pay: 0)
        calc.update(created_by_id: user.id)
      end
      it 'lists checks by length of dwp_result' do
        expect(described_class.by_office_grouped_by_type(user.office_id).count.keys[0]).to eql('Full')
        expect(described_class.by_office_grouped_by_type(user.office_id).count.keys[1]).to eql('Part')
      end
    end
  end
end
