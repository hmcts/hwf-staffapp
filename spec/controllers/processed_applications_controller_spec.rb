require 'rails_helper'

RSpec.describe ProcessedApplicationsController, type: :controller do
  include Devise::TestHelpers

  describe 'GET #index' do
    before do
      get :index
    end

    it 'returns the correct status code' do
      expect(response).to have_http_status(200)
    end

    it 'renders the correct template' do
      expect(response).to render_template(:index)
    end
  end
end
