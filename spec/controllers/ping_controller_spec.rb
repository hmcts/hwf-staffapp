require 'rails_helper'

RSpec.describe PingController, type: :controller do

  include Devise::TestHelpers

  describe 'GET #index' do

    before(:each) { get :index }

    it 'returns success code' do
      expect(response).to have_http_status(:success)
    end

    it 'returns json' do
      expect(response.content_type).to eq('application/json')
    end

    describe 'renders correct json' do

      let(:parsed) { JSON.parse(response.body) }

      it 'key count' do
        expect(parsed.count).to eql(4)
      end

      describe 'values' do
        it 'key count' do
          expect(parsed.count).to eql(4)
        end

        it 'version number' do
          expect(parsed.keys).to include('version_number')
        end

        it 'build date' do
          expect(parsed.keys).to include('build_date')
        end

        it 'commit_id' do
          expect(parsed.keys).to include('commit_id')
        end

        it 'build_tag' do
          expect(parsed.keys).to include('build_tag')
        end
      end
    end
  end
end
