require 'rails_helper'

RSpec.describe Users::FileDownloadController do
  subject { response }

  let(:export_file_storage) { create(:export_file_storage, user: user) }
  let(:user) { create(:mi) }
  let(:user2) { create(:mi) }
  let(:user3) { create(:user) }

  before {
    allow(controller).to receive(:send_data)
  }

  context 'approved user' do
    before { sign_in user }

    describe '#show download button' do
      before { get :show, params: { id: user.id, file_id: export_file_storage.id } }
      it { is_expected.to have_http_status(:success) }
      it { expect(assigns(:storage)).to eq(export_file_storage) }
    end

    describe 'download' do
      before { get :download, params: { id: user.id, file_id: export_file_storage.id } }
      it { is_expected.to have_http_status(:success) }
      it { expect(assigns(:storage)).to eq(export_file_storage) }
      it { expect(controller).to have_received(:send_data) }
    end
  end

  context 'not an owner of the file user' do
    before { sign_in user2 }

    describe '#download' do
      before { get :download, params: { id: user.id, file_id: export_file_storage.id } }
      it { is_expected.to have_http_status(:redirect) }
      it { expect(controller).not_to have_received(:send_data) }
    end
  end

  context 'not allowed to access this page' do
    before { sign_in user3 }

    describe '#download' do
      before { get :show, params: { id: user.id, file_id: export_file_storage.id } }
      it { is_expected.to have_http_status(:redirect) }
      it { expect(controller).not_to have_received(:send_data) }
    end
  end

end
