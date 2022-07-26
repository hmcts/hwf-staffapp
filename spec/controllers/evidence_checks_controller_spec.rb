require 'rails_helper'

RSpec.describe EvidenceChecksController, type: :controller do
  let(:office) { create :office }
  let(:user) { create :staff, office: office }
  let(:filter) { { jurisdiction_id: '' } }

  before do
    sign_in user
  end

  describe 'GET #index' do
    before do
      allow(LoadApplications).to receive(:waiting_for_evidence).with(user, filter).and_return ['waiting apps']
      get :index, params: { filter_applications: filter }
    end

    it 'returns the correct status code' do
      expect(response).to have_http_status(200)
    end

    it 'renders the correct template' do
      expect(response).to render_template(:index)
    end

    describe 'assigns the view models' do
      it 'loads waiting_for_part_payment application for current user' do
        expect(assigns(:waiting_for_evidence)).to eql(['waiting apps'])
      end
    end

    context 'filter' do
      let(:filter) { { jurisdiction_id: '2' } }
      it {
        expect(LoadApplications).to have_received(:waiting_for_evidence).with(user, filter)
      }
    end
  end
end
