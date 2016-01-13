require 'rails_helper'

RSpec.describe BusinessEntitiesController, type: :controller do
  include Devise::TestHelpers

  let!(:office) { create :office }
  let(:admin) { create :admin, office: office }

  describe 'GET #index' do
    subject { response }
    before do
      sign_in admin
      get :index, office_id: office.id
    end

    it { is_expected.to have_http_status(:success) }

    it { is_expected.to render_template(:index) }

    it 'assigns the @jurisdictions variable' do
      expect(assigns(:jurisdictions).count).to eql 3
    end
  end

  describe 'GET #edit' do
    let(:business_entity) { office.business_entities.first }
    subject { response }
    before do
      sign_in admin
      get :edit, office_id: office.id, id: business_entity.id
    end

    it { is_expected.to have_http_status(:success) }

    it { is_expected.to render_template(:edit) }

    it 'assigns the @jurisdictions variable' do
      expect(assigns(:business_entity)).to be_a_kind_of BusinessEntity
    end
  end

  describe 'PUT #update' do
    let(:business_entity) { office.business_entities.first }
    let(:params) { { name: 'Digital - Family', code: code } }

    subject { response }
    before do
      sign_in admin
      put :update, office_id: office.id, id: business_entity.id, business_entity: params
    end

    describe 'with the correct parameters' do
      let(:code) { 'CB975' }

      it { is_expected.to have_http_status(:redirect) }

      it { is_expected.to redirect_to(office_business_entities_path) }

      it 'increments the business_entity count' do
        result = BusinessEntity.where(office_id: business_entity.office_id, jurisdiction_id: business_entity.jurisdiction_id)
        expect(result.count).to eq 2
        expect(result.where(valid_to: nil).count).to eq 1
        expect(result.where('valid_to IS NOT NULL').count).to eq 1
      end
    end

    describe 'with the incorrect parameters' do
      let(:code) { '' }

      it { is_expected.to have_http_status(:success) }

      it { is_expected.to render_template(:edit) }
    end
  end
end
