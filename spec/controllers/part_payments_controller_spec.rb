require 'rails_helper'

RSpec.describe PartPaymentsController, type: :controller do
  let(:office) { create :office }
  let(:user) { create :staff, office: office }
  let(:application) { create(:application, office: office) }
  let(:part_payment) { create(:part_payment, application: application) }

  let(:details) { double }
  let(:processing_details) { double }
  let(:application_overview) { double }
  let(:application_view) { double }
  let(:applicant_view) { double }
  let(:application_result) { double }
  let(:accuracy_form) { double }
  let(:part_payment_result) { double }

  before do
    sign_in user

    allow(PartPayment).to receive(:find).with(part_payment.id.to_s).and_return(part_payment)
    allow(Views::ProcessedData).to receive(:new).with(part_payment.application).and_return(processing_details)
    allow(Views::Overview::Application).to receive(:new).with(part_payment.application).and_return(application_view)
    allow(Views::Overview::Applicant).to receive(:new).with(part_payment.application).and_return(applicant_view)
    allow(Views::Overview::Details).to receive(:new).with(part_payment.application).and_return(details)
    allow(Views::ApplicationResult).to receive(:new).with(part_payment.application).and_return(application_result)
    allow(Forms::PartPayment::Accuracy).to receive(:new).with(part_payment).and_return(accuracy_form)
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

    describe 'assigns the view models' do
      it { expect(assigns(:processing_details)).to eql(processing_details) }
      it { expect(assigns(:application_view)).to eql(application_view) }
      it { expect(assigns(:details)).to eql(details) }
      it { expect(assigns(:applicant)).to eql(applicant_view) }
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

  describe 'POST #accuracy_save' do
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

    describe 'assigns the view models' do
      it { expect(assigns(:part_payment)).to eql(part_payment) }
      it { expect(assigns(:application_view)).to eql(application_view) }
      it { expect(assigns(:result)).to eql(part_payment_result) }
    end
  end

  describe 'POST #summary_save' do
    let(:resolver) { instance_double(ResolverService, complete: nil) }

    before do
      allow(ResolverService).to receive(:new).with(part_payment, user).and_return(resolver)

      post :summary_save, id: part_payment
    end

    it 'returns the correct status code' do
      expect(response).to have_http_status(302)
    end

    it 'redirects to the confirmation page' do
      expect(response).to redirect_to(confirmation_part_payment_path(part_payment))
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
    end
  end

  describe 'GET #return_letter' do
    before { get :return_letter, id: part_payment }

    it 'returns the correct status code' do
      expect(response).to have_http_status(200)
    end

    it 'renders the correct template' do
      expect(response).to render_template :return_letter
    end

    it 'assigns the view models' do
      expect(assigns(:application_view)).to eql(application_view)
    end
  end

  describe 'POST #return_application' do
    let(:resolver_result) { true }
    let(:resolver) { instance_double(ResolverService, return: resolver_result) }

    before do
      allow(ResolverService).to receive(:new).with(part_payment, user).and_return resolver

      post :return_application, id: part_payment
    end

    context 'when no error generated' do
      it 'returns the correct status code' do
        expect(response).to have_http_status(302)
      end

      it 'renders the correct template' do
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when ResolverService returns an error' do
      let(:resolver_result) { false }

      it 'returns the correct status code' do
        expect(response).to have_http_status(302)
      end

      it 'renders the correct template' do
        expect(response).to redirect_to(return_letter_part_payment_path)
      end

      it 'returns an appropriate error in the flash message' do
        expect(flash[:alert]).to eql('This return could not be processed')
      end
    end
  end
end
