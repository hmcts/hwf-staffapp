require 'rails_helper'

RSpec.describe Office, type: :model do

  let(:office)      { FactoryGirl.build :office }

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
end
