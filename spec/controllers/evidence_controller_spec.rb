require 'rails_helper'

RSpec.describe EvidenceController, type: :controller do

  let(:evidence) { create(:evidence_check) }

  describe 'GET #show' do
    before(:each) { get :show, id: evidence }

    it 'returns the correct status code' do
      expect(response.status).to eq 200
    end

    it 'renders the view correctly' do
      expect(response).to render_template('show')
    end
  end
end
