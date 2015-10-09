require 'rails_helper'

RSpec.describe EvidenceController, type: :controller do

  let(:evidence) { build_stubbed(:evidence_check) }

  describe 'GET #show' do
    before do
      allow(EvidenceCheck).to receive(:find)
      get :show, id: evidence
    end

    it 'returns the correct status code' do
      expect(response.status).to eq 200
    end

    it 'renders the correct template' do
      expect(response).to render_template('show')
    end
  end

  describe 'GET #accuracy' do
    before(:each) { get :accuracy, id: evidence }

    it 'returns the correct status code' do
      expect(response.status).to eq 200
    end

    it 'renders the correct template' do
      expect(response).to render_template('accuracy')
    end
  end

  describe 'POST #accuracy_save' do
    before { allow_any_instance_of(Evidence::Forms::Evidence).to receive(:save).and_return(true) }
    before(:each) { post :accuracy_save, id: evidence, evidence: { correct: correct, reason: reason } }

    context 'when the evidence is correct' do
      let(:correct) { true }
      let(:reason) { '' }

      it 'returns the correct status code' do
        expect(response.status).to eq 302
      end
    end

    context 'when the evidence is not correct and reason is given' do
      let(:correct) { false }
      let(:reason) { 'They are earning more than they claimed' }

      it 'returns the correct status code' do
        expect(response.status).to eq 302
      end
    end

    context 'when the evidence is not correct and no reason is given' do
      let(:correct) { false }
      let(:reason) { '' }

      it 'returns the correct status code' do
        expect(response.status).to eq 302
      end
    end
  end

  describe 'GET #income' do
    before { get :income, id: evidence }

    it 'returns the correct status code' do
      expect(response.status).to eq 200
    end

    it 'renders the correct template' do
      expect(response).to render_template('income')
    end
  end

  describe 'POST #income_save' do
    context 'when the form is filled in correctly' do
      before { allow_any_instance_of(Evidence::Forms::Income).to receive(:save).and_return(true) }
      before(:each) { post :income_save, id: evidence, evidence: { amount: amount } }

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
        post :income_save, id: evidence, evidence: { amount: amount }
      end
      let(:amount) { '' }

      it 're-renders the view' do
        expect(response).to render_template :income
      end
    end
  end

  describe 'GET #result' do
    before do
      allow(EvidenceCheck).to receive(:find)
      get :result, id: evidence
    end

    it 'returns the correct status code' do
      expect(response.status).to eq 200
    end

    it 'renders the correct template' do
      expect(response).to render_template :result
    end
  end
end
