require 'rails_helper'

class MockRelation < Array
  def paginate(_options); end
end

RSpec.describe ProcessedApplicationsController do
  let(:user) { create(:user) }

  let(:application1) { build_stubbed(:application, office: user.office) }
  let(:application2) { build_stubbed(:application, office: user.office) }

  let(:applicant) { double }
  let(:fee_status) { instance_double(Views::Overview::FeeStatus) }
  let(:details) { double }
  let(:application_view) { double }
  let(:result) { double }
  let(:processing_details) { double }
  let(:delete_form) { double }

  before do
    sign_in user

    allow(Application).to receive(:find).with(application1.id.to_s).and_return(application1)
    allow(Views::Overview::FeeStatus).to receive(:new).with(application1).and_return(fee_status)
    allow(Views::Overview::Applicant).to receive(:new).with(application1).and_return(applicant)
    allow(Views::Overview::Details).to receive(:new).with(application1).and_return(details)
    allow(Views::Overview::Application).to receive(:new).with(application1).and_return(application_view)
    allow(Views::ApplicationResult).to receive(:new).with(application1).and_return(result)
    allow(Views::ProcessedData).to receive(:new).with(application1).and_return(processing_details)
    allow(Forms::Application::Delete).to receive(:new).with(application1).and_return(delete_form)
  end

  describe 'GET #index' do
    let(:view1) { double }
    let(:view2) { double }
    let(:scope) { double }
    let(:relation) { MockRelation.new([application1, application2]) }
    let(:query) { instance_double(Query::ProcessedApplications, find: scope) }
    let(:page) { nil }
    let(:per_page) { nil }
    let(:sort_hash) { nil }
    let(:sort) { nil }
    let(:filter) { { jurisdiction_id: '' } }

    before do
      allow(Query::ProcessedApplications).to receive(:new).with(user).and_return(query)
      allow(controller).to receive(:policy_scope).with(scope).and_return(relation)
      allow(relation).to receive(:paginate).and_return(relation)
      allow(Views::ApplicationList).to receive(:new).with(application1).and_return(view1)
      allow(Views::ApplicationList).to receive(:new).with(application2).and_return(view2)

      get :index, params: { page: page, per_page: per_page, sort: sort, filter_applications: filter }
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

    context 'when page parameter is set' do
      let(:page) { 4 }

      it 'calls pagination with the page number and defined number per page (settings)' do
        expect(relation).to have_received(:paginate).with(page: 4, per_page: 0)
      end
    end

    context 'when page parameter is not set' do
      it 'calls pagination with page as nil and defined number per page (settings)' do
        expect(relation).to have_received(:paginate).with(page: 0, per_page: 0)
      end
    end

    context 'when the per_page parameter is set to all' do
      let(:per_page) { 'All' }

      it 'calls pagination with the page number and params number per page' do
        expect(relation).not_to have_received(:paginate)
      end
    end
    context 'when the per_page parameter is set numerically' do
      let(:per_page) { 3 }

      it 'calls pagination with the page number and params number per page' do
        expect(relation).to have_received(:paginate).with(page: 0, per_page: 3)
      end
    end

    context 'when the per_page parameter is not set' do
      it 'calls pagination with the page number and defined number per page (settings)' do
        expect(relation).to have_received(:paginate).with(page: 0, per_page: 0)
      end
    end

    context 'when the filter is set' do
      let(:filter) { { jurisdiction_id: '2' } }
      it {
        expect(query).to have_received(:find).with({ "jurisdiction_id" => "2" })
      }
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

    it 'assigns the FeeStatus view model' do
      expect(assigns(:fee_status)).to eql(fee_status)
    end

    it 'assigns the Applicant view model' do
      expect(assigns(:applicant)).to eql(applicant)
    end

    it 'assigns the Details view model' do
      expect(assigns(:details)).to eql(details)
    end

    it 'assigns the Application view model' do
      expect(assigns(:application_view)).to eql(application_view)
    end

    it 'assigns the ApplicationResult view model' do
      expect(assigns(:result)).to eql(result)
    end

    it 'assigns the ProcessedData view model' do
      expect(assigns(:processing_details)).to eql(processing_details)
    end

    it 'assigns the Delete form' do
      expect(assigns(:form)).to eql(delete_form)
    end
  end

  describe 'GET #show' do
    before do
      get :show, params: { id: application1.id }
    end

    it_behaves_like 'renders correctly and assigns required variables'
  end

  describe 'PUT #update' do
    let(:expected_params) { { deleted_reason: 'REASON' } }
    let(:resolver) { instance_double(ResolverService, delete: true) }

    before do
      allow(delete_form).to receive(:update).with(expected_params)
      allow(delete_form).to receive(:save).and_return(form_save)
      allow(ResolverService).to receive(:new).with(application1, user).and_return(resolver)

      put :update, params: { id: application1.id, application: expected_params }
    end

    context 'when the form can be saved' do
      let(:form_save) { true }

      it 'deletes the application using ResolverService' do
        expect(resolver).to have_received(:delete)
      end

      it 'sets a flash message' do
        expect(flash[:notice]).to eql('The application has been deleted')
      end

      it 'redirects to the list of processed applications' do
        expect(response).to redirect_to(processed_applications_path)
      end
    end

    context 'when the form can not be saved' do
      let(:form_save) { false }

      it_behaves_like 'renders correctly and assigns required variables'
    end
  end
end
