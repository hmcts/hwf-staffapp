require 'rails_helper'

RSpec.describe Office, type: :model do

  let(:office)      { build :office }

  it 'has a valid factory' do
    expect(office).to be_valid
  end

  context 'validations' do
    it 'is invalid with no name' do
      office = build(:invalid_office)
      expect(office).to_not be_valid
      expect(office.errors[:name]).to eq ["can't be blank"]
    end

    it 'must have a unique name' do
      original = create(:office)
      duplicate = build(:office, name: original.name)
      expect(duplicate).to be_invalid
    end
  end

  context 'responds to' do
    it 'managers' do
      expect(office).to respond_to(:managers)
    end

    it 'jurisdictions' do
      expect(office).to respond_to(:jurisdictions)
    end
  end

  describe 'jurisdiction' do
    before(:each) do
      office.save
      office.jurisdictions.clear
    end

    it 'can be nil' do
      expect(office.jurisdictions.count).to eq 0
      expect(office).to be_valid
    end

    it 'can be added' do
      office.jurisdictions << create(:jurisdiction)
      office.save
      expect(office.jurisdictions.count).to eq 1
    end

    it 'can have multiple added' do
      office.jurisdictions << create(:jurisdiction)
      office.jurisdictions << create(:jurisdiction)
      office.save
      expect(office.jurisdictions.count).to eq 2
    end
  end

  describe 'managers' do
    let(:office)      { FactoryGirl.create :office }
    it 'returns a list of user in the manager role' do
      User.delete_all
      FactoryGirl.create_list :user, 3, office: office
      FactoryGirl.create :manager, office: office
      expect(office.managers.count).to eql 1
    end
  end
  describe 'managers_email' do
    let(:office)      { FactoryGirl.create :office }
    context 'managers are empty' do
      before(:each) { User.delete_all }
      it 'returns a text prompt' do
        FactoryGirl.create_list :user, 3, office: office
        expect(office.managers_email).to eql('a manager')
      end
    end
    context 'managers are populated' do
      before(:each) { User.delete_all }
      let(:manager1) { FactoryGirl.create :manager, office: office }
      let(:manager2) { FactoryGirl.create :manager, office: office }
      let(:manager_emails) { office.managers_email }

      it 'returns an html string of emails of users in the manager role' do
        [manager1, manager2].each do |manager|
          expect(office.managers_email).to include "#{manager.email}"
          expect(office.managers_email).to include "#{manager.name}"
        end
      end
    end
  end
end
