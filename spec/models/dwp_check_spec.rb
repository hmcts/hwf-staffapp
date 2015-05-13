require 'rails_helper'

RSpec.describe DwpCheck, type: :model do
  let(:user)  { FactoryGirl.create :user }
  let(:check)      { FactoryGirl.build :dwp_check }

  it 'pass factory build' do
    expect(check).to be_valid
  end
  context 'methods' do
    it 'generates a unique token for API checks' do
      check.created_by = FactoryGirl.create(:user, name: 'Test User')
      check.save!
      expect(check).to be_valid
      check_val = "testuser@#{check.created_at.strftime('%y%m%d%H%M%S')}.#{check.unique_number}"
      expect(check.our_api_token).to eql(check_val)
    end
  end
  context 'validations' do
    it 'requires an office_id to be saved' do
      check.office_id = nil
      expect(check).to be_invalid
    end

    it 'requires our_api_token to be between 3 and 50 characters' do
      user = FactoryGirl.create(:user, name: 'a' * 50)
      check.created_by = user
      check.save
      expect(check.our_api_token.length).to eql(50)
    end

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

    it 'requires date of birth to be in the past' do
      check.dob = Date.today
      expect(check).to be_invalid
      expect(check.errors[:dob]).to eq ['must be before today']
    end

    it 'require a NI number' do
      check.ni_number = nil
      expect(check).to be_invalid
    end

    it 'allows a date to check to be passed' do
      check.date_to_check = Date.today
      expect(check).to be_valid
    end

    it 'requires date to check to be in the last three months' do
      check.date_to_check = Date.today.-3.months.+1.day
      expect(check).to be_invalid
      expect(check.errors[:date_to_check]).to eq ['must be in the last 3 months']
    end

    it 'only allow valid NI numbers' do
      check.ni_number = 'wrong'
      expect(check).to be_invalid
    end

    it 'allow a unique number to be set' do
      test_unique = FactoryGirl.create(:dwp_check, created_by: user)
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

  context 'scopes' do
    before(:each) { described_class.delete_all }

    describe 'checks_by_day' do
      let!(:old_check) do
        old = FactoryGirl.create(:dwp_check, created_by: user)
        old.update(created_at: "#{Date.today.-8.days}")
      end
      let!(:new_check) do
        check = FactoryGirl.create(:dwp_check, created_by: user)
        check.update(created_at: "#{Date.today.-5.days}")
      end

      it 'finds only checks for the past week' do
        expect(described_class.checks_by_day.count).to eq 1
      end
    end

    describe 'by_office' do
      let!(:user) do
        user = FactoryGirl.create :user
        user.update(office_id: 1)
        user
      end

      let!(:check) do
        FactoryGirl.create :dwp_check, created_by_id: user.id, office_id: user.office_id
      end

      let!(:another_user) do
        user = FactoryGirl.create :user
        user.update(office_id: 2)
        user
      end

      let!(:another_check) do
        FactoryGirl.create :dwp_check, created_by_id: another_user.id, office_id: another_user.office_id
      end

      it 'lists all the checks from the same office' do
        expect(described_class.by_office(user.office_id).count).to eq 1
        expect(described_class.by_office(another_user.office_id).count).to eq 1
      end
    end
    describe 'by_office_grouped_by_type' do
      let!(:user) do
        user = FactoryGirl.create :user
        user.update(office_id: 1)
        user
      end
      let!(:check) do
        FactoryGirl.create(:dwp_check, dwp_result: 'Deceased', created_by: user, office_id: user.office_id)
      end
      let!(:another_check) do
        FactoryGirl.create(:dwp_check, dwp_result: 'No', created_by_id: user.id, office_id: user.office_id)
      end
      it 'lists checks by length of dwp_result' do
        expect(described_class.by_office_grouped_by_type(user.office_id).count.keys[0]).to eql('No')
        expect(described_class.by_office_grouped_by_type(user.office_id).count.keys[1]).to eql('Deceased')
      end
    end
  end
end
