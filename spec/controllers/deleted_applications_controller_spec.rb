require 'rails_helper'

RSpec.describe DeletedApplicationsController, type: :controller do
  include Devise::TestHelpers

  let(:office) { create(:office) }
  let(:user) { create(:user, office: office) }

  let(:application1) { build_stubbed(:application, office: office) }
  let(:application2) { build_stubbed(:application, office: office) }

  let(:overview) { double }
  let(:result) { double }
  let(:summary) { double }

  before do
    sign_in user

    allow(Application).to receive(:find).with(application1.id.to_s).and_return(application1)
    allow(Views::ApplicationOverview).to receive(:new).with(application1).and_return(overview)
    allow(Views::ApplicationResult).to receive(:new).with(application1).and_return(result)
    allow(Views::ProcessedData).to receive(:new).with(application1).and_return(summary)
  end

  describe 'GET #index' do
    let(:view1) { double }
    let(:view2) { double }
    let(:scope) { double }
    let(:query) { double(find: scope) }

    before do
      allow(Query::DeletedApplications).to receive(:new).with(user).and_return(query)
      allow(controller).to receive(:policy_scope).with(scope).and_return([application1, application2])
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

  describe 'GET #show' do
    before do
      get :show, id: application1.id
    end

    it 'returns the correct status code' do
      expect(response).to have_http_status(200)
    end

    it 'renders the correct template' do
      expect(response).to render_template(:show)
    end

    it 'assigns the Application model' do
      expect(assigns(:application)).to eql(application1)
    end

    it 'assigns the ApplicationOverview view model' do
      expect(assigns(:overview)).to eql(overview)
    end

    it 'assigns the ApplicationResult view model' do
      expect(assigns(:result)).to eql(result)
    end

    it 'assigns the ProcessedData view model' do
      expect(assigns(:summary)).to eql(summary)
    end
  end
end
