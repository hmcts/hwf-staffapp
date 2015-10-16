require 'rails_helper'

RSpec.describe EvidenceController, type: :controller do
  include Devise::TestHelpers

  let(:evidence) { build_stubbed(:evidence_check) }

  before do
    allow(EvidenceCheck).to receive(:find).with(evidence.id.to_s).and_return(evidence)
  end

  describe 'GET #show' do
    before do
      get :show, id: evidence.id
    end

    it 'returns the correct status code' do
      expect(response).to have_http_status(200)
    end

    it 'renders the correct template' do
      expect(response).to render_template('show')
    end

    it 'assigns the overview model' do
      expect(assigns(:overview)).to be_a(Views::ApplicationOverview)
    end
  end

  describe 'GET #accuracy' do
    let(:form) { double }
    let(:expected_form_params) do
      {
        correct: evidence.correct,
        incorrect_reason: evidence.incorrect_reason
      }
    end

    before(:each) do
      allow(Forms::Evidence::Accuracy).to receive(:new).with(evidence).and_return(form)

      get :accuracy, id: evidence.id
    end

    it 'returns the correct status code' do
      expect(response).to have_http_status(200)
    end

    it 'renders the correct template' do
      expect(response).to render_template('accuracy')
    end

    it 'assigns the evidence form' do
      expect(assigns(:form)).to eql(form)
    end
  end

  describe 'POST #accuracy_save', focus: true do
    let(:form) { double }
    let(:expected_form_params) { { correct: true, incorrect_reason: 'reason' } }

    before do
      allow(Forms::Evidence::Accuracy).to receive(:new).with(evidence).and_return(form)
      allow(form).to receive(:update_attributes).with(expected_form_params)
      allow(form).to receive(:save).and_return(form_save)

      post :accuracy_save, id: evidence.id, evidence: expected_form_params
    end

    context 'when the form can be saved' do
      let(:form_save) { true }

      context 'when the form evidence is correct' do
        let(:form) { double(correct: true) }

        it 'redirects to the income page' do
          expect(response).to redirect_to(evidence_income_path(evidence))
        end
      end
      context 'when the form evidence is not correct' do
        let(:form) { double(correct: false) }

        it 'redirects to the income page' do
          expect(response).to redirect_to(evidence_summary_path(evidence))
        end
      end
    end

    context 'when the form can not be saved' do
      let(:form_save) { false }

      it 'assigns the form' do
        expect(assigns(:form)).to eql(form)
      end

      it 'renders the accuracy template again' do
        expect(response).to render_template(:accuracy)
      end
    end
  end

  describe 'GET #income' do
    let(:form) { double }

    before do
      allow(Evidence::Forms::Income).to receive(:new).with(evidence).and_return(form)
      get :income, id: evidence.id
    end

    it 'returns the correct status code' do
      expect(response).to have_http_status(200)
    end

    it 'renders the correct template' do
      expect(response).to render_template('income')
    end

    it 'assigns the income form' do
      expect(assigns(:form)).to eql(form)
    end
  end

  describe 'POST #income_save' do
    let(:form) { double }
    let(:expected_form_params) { { income: '1000' } }

    before do
      allow(Evidence::Forms::Income).to receive(:new).with(evidence).and_return(form)
      allow(form).to receive(:update_attributes).with(expected_form_params)
      allow(form).to receive(:save).and_return(form_save)

      post :income_save, id: evidence.id, evidence: expected_form_params
    end

    context 'when the form is filled in correctly' do
      let(:form_save) { true }
      it 'returns redirects to the result page' do
        expect(response).to redirect_to(evidence_result_path)
      end

      it 'returns the correct status code' do
        expect(response.status).to eq 302
      end
    end

    context 'when the form is filled incorrectly' do
      let(:form_save) { false }

      it 're-renders the view' do
        expect(response).to render_template :income
      end
    end
  end

  describe 'GET #result' do
    before { get :result, id: evidence }

    it 'returns the correct status code' do
      expect(response).to have_http_status(200)
    end

    it 'renders the correct template' do
      expect(response).to render_template :result
    end
  end

  describe 'GET #summary' do
    before { get :summary, id: evidence }

    it 'returns the correct status code' do
      expect(response).to have_http_status(200)
    end

    it 'renders the correct template' do
      expect(response).to render_template :summary
    end
  end

  describe 'POST #summary_save' do
    let(:user)     { create :user, office: create(:office) }
    let(:evidence) { create :evidence_check }

    before(:each) do
      sign_in user
      post :summary_save, id: evidence
    end

    it 'redirects to the correct page' do
      expect(response).to redirect_to(evidence_confirmation_path)
    end

    it 'returns the correct status code' do
      expect(response.status).to eq 302
    end

    it 'updates the completed by field' do
      expect(evidence.completed_by).to eq user
    end
  end

  describe 'GET #confirmation' do
    before(:each) { get :confirmation, id: evidence }

    it 'returns the correct status code' do
      expect(response).to have_http_status(200)
    end

    it 'renders the correct template' do
      expect(response).to render_template('confirmation')
    end

    it 'assigns the evidence check as confirmation' do
      expect(assigns(:confirmation)).to eql(evidence)
    end
  end
end
