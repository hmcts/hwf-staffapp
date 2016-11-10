require 'rails_helper'

RSpec.describe OfficesController, type: :controller do
  let(:office)      { create(:office, jurisdictions: []) }
  let(:user)        { create :user, office: office }

  let(:jurisdiction) { create :jurisdiction }
  let(:valid_params) { attributes_for(:office).merge(jurisdiction_ids: [jurisdiction.id]) }

  before do
    bypass_rescue
    sign_in(user)
  end

  def mock_authorize(record, authorized)
    expectation = receive(:authorize).with(record)
    expectation.and_raise(Pundit::NotAuthorizedError) unless authorized

    expect(controller).to expectation
    expect(controller).to receive(:verify_authorized) if authorized
  end

  shared_examples 'when not authorized' do
    context 'when not authorized' do
      let(:authorized) { false }

      it 'raises Pundit error' do
        expect { subject }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe 'GET #index' do
    before do
      mock_authorize(:office, authorized)
    end

    subject { get :index }

    context 'when authorized' do
      let(:authorized) { true }

      before { subject }

      it 'renders the correct template' do
        expect(response).to render_template(:index)
      end

      it 'assigns all offices' do
        expect(assigns(:offices).size).to eql(Office.count)
      end
    end

    include_examples 'when not authorized'
  end

  describe 'GET #show' do
    before do
      mock_authorize(office, authorized)
    end

    subject { get :show, id: office.id }

    context 'when authorized' do
      let(:authorized) { true }

      before { subject }

      it 'renders the correct template' do
        expect(response).to render_template(:show)
      end

      it 'assigns the office' do
        expect(assigns(:office)).to eql(office)
      end
    end

    include_examples 'when not authorized'
  end

  describe 'GET #new' do
    before do
      mock_authorize(Office, authorized)
    end

    subject { get :new }

    context 'when authorized' do
      let(:authorized) { true }

      before { subject }

      it 'renders the correct template' do
        expect(response).to render_template(:new)
      end

      it 'assigns a new office' do
        expect(assigns(:office)).to be_a_new(Office)
      end
    end

    include_examples 'when not authorized'
  end

  describe 'GET #edit' do
    let(:assigned_jurisdiction) { create :jurisdiction }
    before do
      create :business_entity, office: office, jurisdiction: assigned_jurisdiction
      mock_authorize(office, authorized)
    end

    subject { get :edit, id: office.id }

    context 'when authorized' do
      let(:authorized) { true }

      before { subject }

      it 'renders the correct template' do
        expect(response).to render_template(:edit)
      end

      it 'assigns the office' do
        expect(assigns(:office)).to eql(office)
      end

      it 'assigns only available jurisdictions' do
        expect(assigns(:jurisdictions)).to eq([assigned_jurisdiction])
      end
    end

    include_examples 'when not authorized'
  end

  describe 'POST #create' do
    let(:new_office) { build_stubbed(:office) }
    let(:params) { valid_params }

    before do
      allow(Office).to receive(:new).and_return(new_office)
      mock_authorize(new_office, authorized)
    end

    subject { post :create, office: params }

    context 'when authorized' do
      let(:authorized) { true }

      before do
        allow(new_office).to receive(:errors).and_return(saved ? [] : [double, double])
        expect(new_office).to receive(:save).and_return(saved)
        subject
      end

      context 'when the office can be saved' do
        let(:saved) { true }

        it 'sets a flash notice' do
          expect(flash[:notice]).to eql('Office was successfully created')
        end

        it 'redirects to the office show page' do
          expect(response).to redirect_to(office_path(new_office))
        end
      end

      context 'when the office can not be saved' do
        let(:saved) { false }

        it 'does not redirect' do
          expect(response).not_to be_redirect
        end

        it 'renders the new template' do
          # binding.pry
          expect(response).to render_template(:new)
        end

        it 'assigns the office' do
          expect(assigns(:office)).to eql(new_office)
        end
      end
    end

    include_examples 'when not authorized'
  end

  describe 'PUT #update' do
    let(:existing_office) { office }
    let(:params) { valid_params }

    before do
      allow(Office).to receive(:find).with(existing_office.to_param.to_s).and_return(existing_office)
      mock_authorize(existing_office, authorized)
    end

    subject { put :update, id: existing_office.id, office: params }

    context 'when authorized' do
      let(:authorized) { true }
      let(:manager_setup) { double(setup_profile?: false, in_progress?: false) }

      before do
        allow(ManagerSetup).to receive(:new).and_return(manager_setup)
        allow(ManagerSetup).to receive(:new).and_return(manager_setup)
        allow(existing_office).to receive(:errors).and_return(saved ? [] : [double, double])
        expect(existing_office).to receive(:save).and_return(saved)
        subject
      end

      context 'when the office can be saved' do
        let(:saved) { true }

        it 'sets a flash notice' do
          expect(flash[:notice]).to eql('Office was successfully updated')
        end

        context 'when the user is a manager setting up a new office' do
          context 'when the manager needs to setup their profile' do
            let(:manager_setup) { double(setup_profile?: true, in_progress?: true) }

            it 'redirects to the user edit profile page' do
              expect(response).to redirect_to(edit_user_path(user))
            end
          end
          context 'when the manager does not need to setup their profile' do
            let(:manager_setup) { double(setup_profile?: false, in_progress?: true) }
            it 'redirects to the home page' do
              expect(response).to redirect_to(root_path)
            end
          end
        end

        context 'when the user is not a manager setting up a new office' do
          it 'redirects to the office show page' do
            expect(response).to redirect_to(office_path(existing_office))
          end
        end
      end

      context 'when the office can not be saved' do
        let(:saved) { false }

        it 'renders the new template' do
          expect(response).to render_template(:edit)
        end

        it 'assigns the office' do
          expect(assigns(:office)).to eql(existing_office)
        end
      end
    end

    include_examples 'when not authorized'
  end
end
