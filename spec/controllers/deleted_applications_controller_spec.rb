require 'rails_helper'

RSpec.describe DeletedApplicationsController, type: :controller do
  let(:office) { create(:office) }
  let(:user) { create(:user, office: office) }

  let(:application1) { build_stubbed(:application, office: office) }
  let(:application2) { build_stubbed(:application, office: office) }

  let(:applicant) { double }
  let(:details) { double }
  let(:application_view) { double }
  let(:result) { double }
  let(:processing_details) { double }

  before do
    sign_in user

    allow(Application).to receive(:find).with(application1.id.to_s).and_return(application1)
    allow(Views::Overview::Applicant).to receive(:new).with(application1).and_return(applicant)
    allow(Views::Overview::Details).to receive(:new).with(application1).and_return(details)
    allow(Views::Overview::Application).to receive(:new).with(application1).and_return(application_view)
    allow(Views::ApplicationResult).to receive(:new).with(application1).and_return(result)
    allow(Views::ProcessedData).to receive(:new).with(application1).and_return(processing_details)
  end

  describe 'GET #index' do
    let(:view1) { double }
    let(:view2) { double }
    let(:scope) { double }
    let(:relation) { MockRelation.new([application1, application2]) }
    let(:query) { instance_double(Query::DeletedApplications, find: scope) }
    let(:page) { nil }
    let(:per_page) { nil }

    class MockRelation < Array
      def paginate(_options); end
    end

    before do
      allow(Query::DeletedApplications).to receive(:new).with(user).and_return(query)
      allow(controller).to receive(:policy_scope).with(scope).and_return(relation)
      allow(relation).to receive(:paginate).and_return(relation)
      allow(Views::ApplicationList).to receive(:new).with(application1).and_return(view1)
      allow(Views::ApplicationList).to receive(:new).with(application2).and_return(view2)

      get :index, page: page, per_page: per_page
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
        expect(relation).to have_received(:paginate).with(page: 4, per_page: 2)
      end
    end

    context 'when page parameter is not set' do
      it 'calls pagination with page as nil and defined number per page (settings)' do
        expect(relation).to have_received(:paginate).with(page: 1, per_page: 2)
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
        expect(relation).to have_received(:paginate).with(page: 1, per_page: 3)
      end
    end

    context 'when the per_page parameter is not set' do
      it 'calls pagination with the page number and defined number per page (settings)' do
        expect(relation).to have_received(:paginate).with(page: 1, per_page: 2)
      end
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
  end
end
