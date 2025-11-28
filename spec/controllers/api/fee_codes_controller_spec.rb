# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::FeeCodesController do
  let(:user) { create(:user) }

  describe 'GET #index without authentication' do
    before do
      get :index
    end

    it 'unauthorized access redirects' do
      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'GET #index' do
    before do
      sign_in user
      allow(FeeCodesLoaderService).to receive(:load_fees).and_return([{ 'code' => 'FEE0001', 'amount' => 100 }])
      get :index
    end

    it 'success' do
      expect(response).to have_http_status(:ok)
    end

    it 'load the fees' do
      expect(FeeCodesLoaderService).to have_received(:load_fees)
      list = response.parsed_body
      expect(list[0]['code']).to eq('FEE0001')
      expect(list[0]['amount']).to eq(100)
    end
  end

end
