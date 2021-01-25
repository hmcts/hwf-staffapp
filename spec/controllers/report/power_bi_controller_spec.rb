require 'rails_helper'

RSpec.describe Report::PowerBiController do

  let(:admin) { create :admin_user }
  before { sign_in admin }

  describe 'GET #power_bi' do
    before { get :show }

    subject { response }

    it { is_expected.to have_http_status(:success) }

    it { is_expected.to render_template :power_bi }

    describe 'assigns form object' do
      subject { assigns(:form) }

      it { is_expected.to be_a_kind_of Forms::FinanceReport }
    end
  end

  describe 'PUT #power_bi_export' do
    subject { response }
    let(:power_bi_export_class) { instance_double('Views::Reports::PowerBiExport') }
    let(:temp_file) { Tempfile.new('foo') }

    before {
      allow(power_bi_export_class).to receive(:zipfile_path).and_return temp_file.path
      allow(Views::Reports::PowerBiExport).to receive(:new).and_return power_bi_export_class
      put :data_export
    }

    it { is_expected.to have_http_status(:success) }

    it 'sets the file type' do
      expect(power_bi_export_class).to have_received(:zipfile_path)
    end

  end

end
