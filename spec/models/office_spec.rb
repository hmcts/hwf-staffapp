require 'rails_helper'

RSpec.describe Office, type: :model do

  let(:office)      { build :office }

  context 'validations' do
    it 'not accept office with no name' do
      office.name = nil
      expect(office).to be_invalid
      expect(office.errors[:name]).to eq ["can't be blank"]
    end

    it 'validate' do
      expect(office).to be_valid
    end
  end

  context 'responds to' do
    it 'managers' do
      expect(office).to respond_to(:managers)
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
      it 'returns an html string of emails of users in the manager role' do
        manager1 = FactoryGirl.create :manager, office: office
        manager2 = FactoryGirl.create :manager, office: office
        expected = "<a href=\"mailto:#{manager1.email}\">#{manager1.name}</a>, <a href=\"mailto:#{manager2.email}\">#{manager2.name}</a>"
        expect(office.managers_email).to eql(expected)
      end
    end
  end
end
