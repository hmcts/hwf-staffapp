require 'rails_helper'

RSpec.describe CalculatorController, type: :controller do

  include Devise::TestHelpers

  context 'as a signed in user' do
    let(:user)    { create :user }
    before(:each) do
      sign_in user
    end

    describe 'GET #income' do
      before(:each) { get :income }
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'renders the income calculator template' do
        expect(response).to render_template('income')
      end
    end

    describe 'POST #record_search' do
      context 'with valid attributes' do
        let(:valid_attributes) {
          {
            fee: 410,
            married: false,
            children: 2,
            income: 2000,
            remittance: 200,
            to_pay: 210
          }
        }
        it 'returns json' do
          post :record_search, r2_calculator: valid_attributes
          expect(response.content_type).to eq('application/json')
        end
        it 'saves the record into the database' do
          expect {
            post :record_search, r2_calculator: valid_attributes
          }.to change(R2Calculator, :count).by(1)
        end
      end
      context 'with invalid attributes' do
        let(:invalid_attributes) {
          {
            fee: 'invalid',
            married: false,
            children: 2,
            income: 2000,
            remittance: 200,
            to_pay: 210
          }
        }

        it 'returns json object errors' do
          post :record_search, r2_calculator: invalid_attributes
          expect(response.content_type).to eq('application/json')
          parsed = JSON.parse(response.body)
          expect(parsed.count).to eql(2)
          expect(parsed['fee']).to eql(['is not a number'])
          expect(parsed['base']).to eql(['remittances must equal fee'])
        end
        it 'does not save the record into the database' do
          expect {
            post :record_search, r2_calculator: invalid_attributes
          }.to_not change(R2Calculator, :count)
        end
      end
    end
  end
end
