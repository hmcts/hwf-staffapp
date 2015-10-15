require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do
  include Devise::TestHelpers

  let(:payment) { build_stubbed(:payment) }

  let(:processing_details) { double }
  let(:application_overview) { double }
  let(:application_result) { double }

  before do
    allow(Payment).to receive(:find).with(payment.id.to_s).and_return(payment)
    allow(Views::ProcessingDetails).to receive(:new).with(payment).and_return(processing_details)
    allow(Views::ApplicationOverview).to receive(:new).with(payment.application).and_return(application_overview)
    allow(Views::ApplicationResult).to receive(:new).with(payment.application).and_return(application_result)
  end

  describe 'GET #show' do
    before do
      get :show, id: payment.id
    end

    it 'returns the correct status code' do
      expect(response).to have_http_status(200)
    end

    it 'renders the correct template' do
      expect(response).to render_template('show')
    end

    it 'assigns the view models' do
      expect(assigns(:processing_details)).to eql(processing_details)
      expect(assigns(:overview)).to eql(application_overview)
      expect(assigns(:result)).to eql(application_result)
    end
  end

end
