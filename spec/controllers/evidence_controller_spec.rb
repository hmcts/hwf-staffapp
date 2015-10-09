require 'rails_helper'

RSpec.describe EvidenceController, type: :controller do

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
      expect(assigns(:overview)).to be_a(Evidence::Views::Overview)
    end
  end

  describe 'GET #accuracy' do
    let(:form) { double }
    let(:expected_form_params) do
      {
        id: evidence.id,
        correct: evidence.correct,
        reason: evidence.reason.try(:explanation)
      }
    end

    before(:each) do
      allow(Evidence::Forms::Evidence).to receive(:new).with(expected_form_params).and_return(form)

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

  describe 'POST #accuracy_save' do
    let(:form) { double }
    let(:params) { { correct: true, reason: 'reason' } }
    let(:expected_form_params) { { id: evidence.id.to_s }.merge(params) }

    before do
      allow(Evidence::Forms::Evidence).to receive(:new).with(expected_form_params).and_return(form)
      allow(form).to receive(:save).and_return(form_save)

      post :accuracy_save, id: evidence.id, evidence: params
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
    let(:expected_form_params) do
      {
        id: evidence.id,
        amount: evidence.income
      }
    end

    before do
      allow(Evidence::Forms::Income).to receive(:new).with(expected_form_params).and_return(form)
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
    context 'when the form is filled in correctly' do
      before { allow_any_instance_of(Evidence::Forms::Income).to receive(:save).and_return(true) }
      before(:each) { post :income_save, id: evidence.id, evidence: { amount: amount } }

      let(:amount) { '50' }

      it 'returns the correct status code' do
        expect(response).to redirect_to(evidence_result_path)
      end

      it 'returns the correct status code' do
        expect(response.status).to eq 302
      end
    end

    context 'when the form is filled in with nothing' do
      before do
        allow_any_instance_of(Evidence::Forms::Income).to receive(:save).and_return(false)
        post :income_save, id: evidence.id, evidence: { amount: amount }
      end
      let(:amount) { '' }

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
