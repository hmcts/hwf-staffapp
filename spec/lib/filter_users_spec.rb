require 'rails_helper'

RSpec.describe FilterUsers do
  before do
    create_list :active_user, 2
    create :inactive_user
  end

  let(:filters) { { office: '', activity: 'active' } }
  let(:users) { User.all }
  let(:active_users) { User.active }
  let(:inactive_users) { User.inactive }
  let(:filtered_users) { described_class.new(users, filters).apply }

  describe 'FILTER_LIST' do
    it 'includes the activity and office filters' do
      res = (described_class::FILTER_LIST & [:office, :activity]).count
      expect(res).to eq 2
    end
  end

  describe '#apply' do
    it 'returns an ActiveRecord collection' do
      expect(filtered_users).to be_an User::ActiveRecord_Relation
    end

    context 'without filters' do
      let(:filters) { {} }
      it 'returns all users' do
        res = (filtered_users & User.all).count
        expect(res).to eq 3
      end
    end

    context 'with filters' do
      context 'activity filter' do
        context 'for active users' do
          it 'returns the active users' do
            res = (filtered_users & active_users).count
            expect(res).to eq 2
          end
        end

        context 'for inactive users' do
          let(:filters) { { activity: 'inactive' } }

          it 'returns the inactive users' do
            res = (filtered_users & inactive_users).count
            expect(res).to eq 1
          end
        end
      end

      context 'office filter' do
        let(:office_id) { Office.first.id }
        let(:filters) { { office: office_id } }
        let(:filtered_users_offices) { filtered_users.map(&:office_id).uniq }

        it 'returns users only from one office' do
          expect(filtered_users_offices.count).to eq 1
        end

        it 'returns users from the specified office' do
          expect(filtered_users_offices.first).to eq office_id
        end
      end
    end
  end
end
