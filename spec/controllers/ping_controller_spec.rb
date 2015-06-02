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
    it 'renders correct json keys' do
      parsed = JSON.parse(response.body)
      expect(parsed.count).to eql(4)
      expect(parsed.keys[0]).to eql('version_number')
      expect(parsed.keys[1]).to eql('build_date')
      expect(parsed.keys[2]).to eql('commit_id')
      expect(parsed.keys[3]).to eql('build_tag')
    end
  end
end
