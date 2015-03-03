require 'rails_helper'

RSpec.describe Office, type: :model do

  context 'validations' do

    let(:office)      { FactoryGirl.build :office }

    it 'not accept office with no name' do
      office.name = nil
      expect(office).to be_invalid
      expect(office.errors[:name]).to eq ["can't be blank"]
    end

    it 'validate' do
      expect(office).to be_valid
    end

  end
end
