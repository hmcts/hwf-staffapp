require 'rails_helper'

RSpec.describe EvidenceChecksController do
  let(:office) { create(:office) }
  let(:user) { create(:staff, office: office) }
  let(:filter) { { jurisdiction_id: '' } }
  let(:sort) { {} }

  before do
    sign_in user
  end

  describe 'GET #index' do
    let(:application1) do
      create(:application, :waiting_for_evidence_state, office: office, completed_at: 1.day.ago)
    end
    let(:application2) do
      create(:application, :waiting_for_evidence_state, office: office, completed_at: 2.days.ago)
    end

    before do
      application1
      application2
      allow(LoadApplications).to receive(:waiting_for_evidence).and_call_original
      get :index, params: { filter_applications: filter }
    end

    it 'returns the correct status code' do
      expect(response).to have_http_status(200)
    end

    it 'renders the correct template' do
      expect(response).to render_template(:index)
    end

    describe 'assigns the view models' do
      it 'wraps the waiting applications in ApplicationList views' do
        expect(assigns(:waiting_for_evidence)).to all(be_a(Views::ApplicationList))
      end

      it 'loads the evidence checks for the waiting applications' do
        evidence_checks = assigns(:waiting_for_evidence).map(&:evidence_or_part_payment)
        expect(evidence_checks).to eq([application1.evidence_check, application2.evidence_check])
      end
    end

    context 'filter' do
      let(:filter) { { jurisdiction_id: '2' } }
      it {
        expect(LoadApplications).to have_received(:waiting_for_evidence).with(user, filter, sort)
      }
    end

    context 'sorting params' do
      before do
        get :index, params: { filter_applications: { jurisdiction_id: '',
                                                     order_choice: 'Ascending',
                                                     sort_by: 'case_number',
                                                     sort_to: 'desc' } }
      end

      it 'passes the sort options to the loader' do
        expect(LoadApplications).to have_received(:waiting_for_evidence).with(
          user, { jurisdiction_id: '' },
          { order_choice: 'Ascending', sort_by: 'case_number', sort_to: 'desc' }
        )
      end
    end

    context 'pagination' do
      before do
        get :index, params: { filter_applications: filter, page: 2, per_page: 1 }
      end

      it 'shows only the requested page of applications' do
        evidence_checks = assigns(:waiting_for_evidence).map(&:evidence_or_part_payment)
        expect(evidence_checks).to eq([application2.evidence_check])
      end

      it 'exposes the paginated collection for the view' do
        expect(assigns(:paginate).total_entries).to eq(2)
      end
    end

    context 'pagination combined with secondary sorting' do
      before do
        get :index, params: { filter_applications: filter.merge(sort_by: 'form_name', sort_to: 'asc'),
                              page: 1, per_page: 1 }
      end

      it 'paginates the sorted list without errors' do
        expect(assigns(:waiting_for_evidence).size).to eq(1)
      end
    end
  end
end
