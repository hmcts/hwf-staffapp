require 'rails_helper'

RSpec.describe ProcessedApplicationsController, type: :controller do
  include Devise::TestHelpers

  let(:user) { create(:user) }

  let(:application1) { build_stubbed(:application) }
  let(:application2) { build_stubbed(:application) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    let(:view1) { double }
    let(:view2) { double }
    let(:query) { double(find: [application1, application2]) }

    before do
      allow(Query::ProcessedApplications).to receive(:new).and_return(query)
      allow(Views::ApplicationList).to receive(:new).with(application1).and_return(view1)
      allow(Views::ApplicationList).to receive(:new).with(application2).and_return(view2)

      get :index
    end

    it 'returns the correct status code' do
      expect(response).to have_http_status(200)
    end

    it 'renders the correct template' do
      expect(response).to render_template(:index)
    end

    it 'assigns the list of processed applications' do
      expect(assigns(:applications)).to eq([view1, view2])
    end
  end
end
