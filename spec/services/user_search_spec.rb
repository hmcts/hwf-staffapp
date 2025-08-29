require 'rails_helper'

RSpec.describe UserSearch do
  let(:office_1) { create(:office) }
  let(:office_2) { create(:office) }

  let(:user_1) { create(:active_user, name: 'John Doe', office: office_1) }
  let(:user_2) { create(:active_user, name: 'Bob Jones', office: office_1) }
  let(:user_3) { create(:active_user, name: 'Bob Jones', office: office_2) }

  let(:filters) { { office: '', name: '' } }
  let(:users) { User.all }
  let(:search_users) { described_class.new(users, filters).apply }

  describe 'FILTER_LIST' do
    it 'includes the name and office filters' do
      res = (described_class::FILTER_LIST & [:office, :name]).count
      expect(res).to eq 2
    end
  end

  describe '#apply' do
    it 'returns an ActiveRecord collection' do
      expect(search_users).to be_an ActiveRecord::Relation
    end

    context 'without filters' do
      let(:filters) { {} }

      it 'returns all users' do
        expect(search_users).to match_array(User.all)
      end
    end

    context 'with filters' do
      context 'name filter' do
        let(:filters) { { name: 'John' } }

        it 'returns matching users by name' do
          expect(search_users).to match_array([user_1])
        end
      end

      context 'office filter' do
        let(:filters) { { office: office_1.id } }

        it 'returns users from the specified office' do
          expect(search_users).to match_array([user_1, user_2])
        end
      end

      context 'combined filters' do
        let(:filters) { { name: 'Bob', office: office_1.id } }

        it 'returns users matching both name and office' do
          expect(search_users).to match_array([user_2])
        end
      end
    end
  end
end
