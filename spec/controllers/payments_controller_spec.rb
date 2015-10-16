require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do
  include Devise::TestHelpers

  let(:payment) { build_stubbed(:payment) }

  let(:processing_details) { double }
  let(:application_overview) { double }
  let(:application_result) { double }
  let(:accuracy_form) { double }
  let(:payment_result) { double }

  before do
    allow(Payment).to receive(:find).with(payment.id.to_s).and_return(payment)
    allow(Views::ProcessingDetails).to receive(:new).with(payment).and_return(processing_details)
    allow(Views::ApplicationOverview).to receive(:new).with(payment.application).and_return(application_overview)
    allow(Views::ApplicationResult).to receive(:new).with(payment.application).and_return(application_result)
    allow(Forms::Accuracy).to receive(:new).with(payment).and_return(accuracy_form)
    allow(Views::Payment::Result).to receive(:new).with(payment).and_return(payment_result)
  end

  describe 'GET #show' do
    before do
      get :show, id: payment.id
    end

    it 'returns the correct status code' do
      expect(response).to have_http_status(200)
    end

    it 'renders the correct template' do
      expect(response).to render_template(:show)
    end

    it 'assigns the view models' do
      expect(assigns(:processing_details)).to eql(processing_details)
      expect(assigns(:overview)).to eql(application_overview)
      expect(assigns(:result)).to eql(application_result)
    end
  end

  describe 'GET #accuracy' do
    before do
      get :accuracy, id: payment.id
    end

    it 'returns the correct status code' do
      expect(response).to have_http_status(200)
    end

    it 'renders the correct template' do
      expect(response).to render_template(:accuracy)
    end

    it 'assigns the form object' do
      expect(assigns(:form)).to eql(accuracy_form)
    end
  end

  describe 'POST #accuracy_save', focus: true do
    let(:expected_form_params) { { correct: true, incorrect_reason: 'reason' } }

    before do
      allow(accuracy_form).to receive(:update_attributes).with(expected_form_params)
      allow(accuracy_form).to receive(:save).and_return(form_save)

      post :accuracy_save, id: payment.id, payment: expected_form_params
    end

    context 'when the form can be saved' do
      let(:form_save) { true }

      it 'redirects to the summary page' do
        expect(response).to redirect_to(summary_payment_path(payment))
      end
    end

    context 'when the form can not be saved' do
      let(:form_save) { false }

      it 'assigns the form' do
        expect(assigns(:form)).to eql(accuracy_form)
      end

      it 'renders the accuracy template again' do
        expect(response).to render_template(:accuracy)
      end
    end
  end

  describe 'GET #summary' do
    before { get :summary, id: payment }

    it 'returns the correct status code' do
      expect(response).to have_http_status(200)
    end

    it 'renders the correct template' do
      expect(response).to render_template :summary
    end

    it 'assigns the view models' do
      expect(assigns(:overview)).to eql(application_overview)
      expect(assigns(:result)).to eql(payment_result)
    end
  end
end
