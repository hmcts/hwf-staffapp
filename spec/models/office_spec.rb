require 'rails_helper'

RSpec.describe Office, type: :model do

  let(:office) { build :office }

  it { is_expected.to have_many(:users) }
  it { is_expected.to have_many(:applications) }
  it { is_expected.to have_many(:office_jurisdictions) }
  it { is_expected.to have_many(:jurisdictions).through(:office_jurisdictions) }

  it 'has a valid factory' do
    expect(office).to be_valid
  end

  context 'validations' do
    let(:office) { build(:invalid_office) }

    before { office.valid? }

    describe 'is invalid with no name' do
      it { expect(office).not_to be_valid }
      it { expect(office.errors[:name]).to eq ['Enter the office name'] }
    end

    it 'must have a unique name' do
      original = create(:office)
      duplicate = build(:office, name: original.name)
      expect(duplicate).to be_invalid
    end
  end

  describe 'managers' do
    let(:office)      { FactoryGirl.create :office }

    it 'returns a list of user in the manager role' do
      User.delete_all
      FactoryGirl.create_list :user, 3, office: office
      FactoryGirl.create :manager, office: office
      expect(office.managers.count).to eq 1
    end
  end

  describe 'business_entities' do
    subject { office.business_entities.count }

    let(:office) { create :office }

    context 'before editing' do
      it { is_expected.to eq 2 }
    end

    context 'after "deleting" one' do
      before { office.business_entities.first.update_attributes(valid_to: Time.zone.now + 1.day) }

      it { is_expected.to eq 1 }
    end
  end
end
