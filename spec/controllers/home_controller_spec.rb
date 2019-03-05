require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  let(:staff)   { create :staff }
  let(:manager) { create :manager }
  let(:admin)   { create :admin_user }

  describe 'GET #index' do
    context 'when the user is authenticated' do
      describe 'DWP status banner' do

        before { sign_in staff }

        subject { assigns(:state) }

        context 'when less than 25% of the last dwp_results are "400 Bad Request"' do
          before do
            build_dwp_checks_with_bad_requests(8, 2)
            get :index
          end

          it { is_expected.to eql 'online' }
        end

        context 'when more than 25% of the last dwp_results are "400 Bad Request"' do
          before do
            build_dwp_checks_with_bad_requests(6, 4)
            get :index
          end

          it { is_expected.to eql 'warning' }
        end

        context 'checks for "Server broke connection" messages too' do
          before do
            build_dwp_checks_with_all_errors
            get :index
          end

          it { is_expected.to eql 'warning' }
        end

        context 'when more than 50% of the last dwp_results are "400 Bad Request"' do
          before do
            build_dwp_checks_with_bad_requests
            get :index
          end

          it { is_expected.to eql 'offline' }
        end
      end

      context 'as a user' do

        before do
          sign_in staff
          get :index
        end

        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end

        it 'renders the index view' do
          expect(response).to render_template :index
        end

        it 'assigns the search form' do
          expect(assigns(:online_search_form)).to be_a(Forms::Search)
        end

        it 'assigns the DwpMonitor state' do
          expect(assigns(:state)).to be_a String
        end

        it "assigns last updated applications" do
          expect(assigns(:last_updated_applications)).to eq([])
        end
      end

      context 'as a user with applications' do
        let(:application) { build_stubbed :application }

        before do
          query = instance_double('Query::LastUpdatedApplications')
          allow(Query::LastUpdatedApplications).to receive(:new).and_return query
          allow(query).to receive(:find).with(limit: 20).and_return [application]
          sign_in staff
          get :index
        end

        it "assigns last updated applications" do
          expect(assigns(:last_updated_applications)).to eq([application])
        end

      end

      context 'as an admin' do
        before do
          Office.delete_all
          create_list :benefit_check, 2, user_id: manager.id
          sign_in admin
          get :index
        end
        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end
      end
    end

    context 'as a manager' do
      before do
        create_list :benefit_check, 2, user_id: manager.id
        sign_in manager
        get :index
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'renders the index view' do
        expect(response).to render_template :index
      end

      it 'assigns the search form' do
        expect(assigns(:online_search_form)).to be_a(Forms::Search)
      end
    end

    context 'when the user is not authenticated' do

      before do
        sign_out staff
        get :index
      end

      it 'redirects to sign in page' do
        expect(response).to redirect_to(:new_user_session)
      end
    end
  end

  describe 'GET #completed_search' do
    let(:application) { build_stubbed(:application) }
    let(:search) { nil }

    before do
      allow(Application).to receive(:find_by).with(reference: application.reference).and_return(application)
      allow(ApplicationSearch).to receive(:new).with(reference, user).and_return(search)

      sign_in(user)
      get :completed_search, completed_search: { reference: reference }
    end

    let(:user) { staff }

    context 'when reference parameter is empty' do
      let(:reference) { nil }

      it 'renders the index template' do
        expect(response).to render_template(:index)
      end

      describe 'assigns the search forms' do
        it { expect(assigns(:completed_search_form)).to be_a(Forms::Search) }
        it { expect(assigns(:online_search_form)).to be_a(Forms::Search) }
      end
    end

    context 'when reference parameter is present' do
      let(:reference) { 'whatever' }

      let(:search) { instance_double(ApplicationSearch, call: completed_result, error_message: completed_error) }

      context 'when the search returns nil and an error' do
        let(:completed_result) { nil }
        let(:completed_error) { 'Some error' }

        it 'renders the index template' do
          expect(response).to render_template(:index)
        end

        describe 'assigns the search form' do
          it { expect(assigns(:completed_search_form)).to be_a(Forms::Search) }
          it { expect(assigns(:online_search_form)).to be_a(Forms::Search) }
        end

        it 'assigns the DwpMonitor state' do
          expect(assigns(:state)).to be_a String
        end
      end
    end
  end

  describe 'GET #completed_search with pagination' do
    let(:application) { build_stubbed(:application) }
    let(:user) { staff }
    let(:reference) { 'whatever' }
    let(:search) { instance_double(ApplicationSearch, 'search_class', call: completed_result, error_message: completed_error) }

    before do
      allow(Application).to receive(:find_by).with(reference: application.reference).and_return(application)
      allow(ApplicationSearch).to receive(:new).with(reference, user).and_return(search)
      allow(search).to receive(:paginate_search_results).with(sort_by: 'first_name', sort_to: 'asc', page: '2').and_return(search)

      sign_in(user)
      get :completed_search, completed_search: { reference: reference }, sort_to: 'asc', sort_by: 'first_name', page: 2
    end

    context 'when the search returns a results' do
      let(:completed_error) { nil }
      let(:completed_result) { ['asd'] }

      it 'renders the index view' do
        expect(response).to render_template :index
      end

      it 'does assign the DwpMonitor state' do
        expect(assigns(:state)).not_to be nil
      end
    end
  end

  describe 'POST #online_search' do
    let(:online_application) { build_stubbed(:online_application, :with_reference) }
    let(:application) { nil }

    before do
      allow(OnlineApplication).to receive(:find_by).with(reference: online_application.reference).and_return(online_application)
      allow(OnlineApplication).to receive(:find_by).with(reference: 'HWF-WRO-NG').and_return(nil)
      allow(Application).to receive(:find_by).with(reference: online_application.reference).and_return(application) unless application.nil?

      sign_in(user)
      post :online_search, online_search: search_params
    end

    let(:user) { staff }

    context 'when reference parameter is empty' do
      let(:search_params) { { reference: nil } }

      it 'renders the index template' do
        expect(response).to render_template(:index)
      end

      describe 'assigns the search forms' do
        it { expect(assigns(:online_search_form)).to be_a(Forms::Search) }
        it { expect(assigns(:completed_search_form)).to be_a(Forms::Search) }
      end
    end

    context 'when reference parameter is present' do
      let(:search_params) { { reference: reference } }

      context 'when no online application is found with that reference' do
        let(:reference) { 'WRONG' }

        it 'renders the index template' do
          expect(response).to render_template(:index)
        end

        describe 'assigns the search forms' do
          it { expect(assigns(:online_search_form)).to be_a(Forms::Search) }
          it { expect(assigns(:completed_search_form)).to be_a(Forms::Search) }
        end

        it 'assigns the DwpMonitor state' do
          expect(assigns(:state)).to be_a String
        end
      end

      context 'when an online application is found with that reference' do
        let(:reference) { online_application.reference }

        it 'redirects to the edit page for that online application' do
          expect(response).to redirect_to(edit_online_application_path(online_application))
        end

        it 'does not assign the DwpMonitor state' do
          expect(assigns(:state)).to be nil
        end
      end

      context 'when an application exists with the reference' do
        let(:reference) { online_application.reference }
        let(:application) { build_stubbed(:application, reference: online_application.reference, office: user.office) }

        it 'renders the index template' do
          expect(response).to render_template(:index)
        end
      end
    end
  end

  describe '#dwp_maintenance?' do
    subject do
      Timecop.freeze(current_time) do
        controller.dwp_maintenance?
      end
    end

    context 'when the current time is before 7am 25th April 2016' do
      let(:current_time) { Time.zone.parse('23/04/2016 13:00:00') }

      it { is_expected.to be true }
    end

    context 'when the current time is at or after 8pm 24th April 2016' do
      let(:current_time) { Time.zone.parse('24/04/2016 20:00:00') }

      it { is_expected.to be false }
    end
  end
end
