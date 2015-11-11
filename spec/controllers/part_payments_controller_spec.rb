require 'rails_helper'

RSpec.describe PartPaymentsController, type: :controller do
  include Devise::TestHelpers

  let(:part_payment) { build_stubbed(:part_payment) }

  let(:processing_details) { double }
  let(:application_overview) { double }
  let(:application_result) { double }
  let(:accuracy_form) { double }
  let(:part_payment_result) { double }

  before do
    allow(PartPayment).to receive(:find).with(part_payment.id.to_s).and_return(part_payment)
    allow(Views::ProcessingDetails).to receive(:new).with(part_payment).and_return(processing_details)
    allow(Views::ApplicationOverview).to receive(:new).with(part_payment.application).and_return(application_overview)
    allow(Views::ApplicationResult).to receive(:new).with(part_payment.application).and_return(application_result)
    allow(Forms::Accuracy).to receive(:new).with(part_payment).and_return(accuracy_form)
    allow(Views::PartPayment::Result).to receive(:new).with(part_payment).and_return(part_payment_result)
  end

  describe 'GET #show' do
    before do
      get :show, id: part_payment.id
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
      get :accuracy, id: part_payment.id
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

      post :accuracy_save, id: part_payment.id, part_payment: expected_form_params
    end

    context 'when the form can be saved' do
      let(:form_save) { true }

      it 'redirects to the summary page' do
        expect(response).to redirect_to(summary_part_payment_path(part_payment))
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
    before { get :summary, id: part_payment }

    it 'returns the correct status code' do
      expect(response).to have_http_status(200)
    end

    it 'renders the correct template' do
      expect(response).to render_template :summary
    end

    it 'assigns the view models' do
      expect(assigns(:part_payment)).to eql(part_payment)
      expect(assigns(:overview)).to eql(application_overview)
      expect(assigns(:result)).to eql(part_payment_result)
    end
  end

  describe 'POST #summary_save' do
    let(:current_time) { Time.zone.now }
    let(:user) { create :user }
    let(:part_payment) { create(:part_payment) }

    before do
      allow(PartPayment).to receive(:find).with(part_payment.id).and_return(part_payment)

      Timecop.freeze(current_time) do
        sign_in user
        get :summary_save, id: part_payment
      end
    end

    it 'returns the correct status code' do
      expect(response).to have_http_status(302)
    end

    it 'redirects to the confirmation page' do
      expect(response).to redirect_to(confirmation_part_payment_path(part_payment))
    end

    it 'updates the part_payment completed_at and completed_by' do
      part_payment.reload

      expect(part_payment.completed_at).to eql(current_time)
      expect(part_payment.completed_by).to eql(user)
    end
  end

  describe 'GET #confirmation' do
    before { get :confirmation, id: part_payment }

    it 'returns the correct status code' do
      expect(response).to have_http_status(200)
    end

    it 'renders the correct template' do
      expect(response).to render_template :confirmation
    end

    it 'assigns the view models' do
      expect(assigns(:result)).to eql(part_payment_result)
      expect(assigns(:overview)).to eql(application_overview)
    end
  end
end
