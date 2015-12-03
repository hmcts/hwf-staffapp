require 'rails_helper'

RSpec.describe ProcessedApplicationsController, type: :controller do
  include Devise::TestHelpers

  let(:user) { create(:user) }

  let(:application1) { build_stubbed(:application) }
  let(:application2) { build_stubbed(:application) }

  let(:overview) { double }
  let(:result) { double }
  let(:remove_form) { double }

  before do
    sign_in user

    allow(Application).to receive(:find).with(application1.id.to_s).and_return(application1)
    allow(Views::ApplicationOverview).to receive(:new).with(application1).and_return(overview)
    allow(Views::ApplicationResult).to receive(:new).with(application1).and_return(result)
    allow(Forms::Application::Remove).to receive(:new).with(application1).and_return(remove_form)
  end

  describe 'GET #index' do
    let(:view1) { double }
    let(:view2) { double }
    let(:query) { double(find: [application1, application2]) }

    before do
      allow(Query::ProcessedApplications).to receive(:new).with(user).and_return(query)
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

  shared_examples 'renders correctly and assigns required variables' do
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

    it 'assigns the Remove form' do
      expect(assigns(:form)).to eql(remove_form)
    end
  end

  describe 'GET #show' do
    before do
      get :show, id: application1.id
    end

    include_examples 'renders correctly and assigns required variables'
  end

  describe 'PUT #update' do
    let(:expected_params) { { removed_reason: 'REASON' } }
    let(:resolver) { double(remove: true) }

    before do
      expect(remove_form).to receive(:update_attributes).with(expected_params)
      allow(remove_form).to receive(:save).and_return(form_save)
      allow(ResolverService).to receive(:new).with(application1, user).and_return(resolver)

      put :update, id: application1.id, application: expected_params
    end

    context 'when the form can be saved' do
      let(:form_save) { true }

      it 'removes the application using ResolverService' do
        expect(resolver).to have_received(:remove)
      end

      it 'sets a flash message' do
        expect(flash[:notice]).to eql('The application has been removed')
      end

      it 'redirects to the list of processed applications' do
        expect(response).to redirect_to(processed_applications_path)
      end
    end

    context 'when the form can not be saved' do
      let(:form_save) { false }

      include_examples 'renders correctly and assigns required variables'
    end
  end
end
