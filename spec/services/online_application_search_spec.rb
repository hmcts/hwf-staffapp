require 'rails_helper'

RSpec.describe OnlineApplicationSearch do
  subject(:service) { described_class.new(reference, user) }

  include Rails.application.routes.url_helpers

  let(:reference) { nil }
  let(:user) { create(:staff) }

  it { is_expected.to respond_to :error_message }

  describe '#online' do
    subject { service.online }

    let(:existing_reference) { 'HWF-123-ABC' }
    let(:wrong_reference) { 'HWF-WRO-NG' }
    let(:online_application) { build_stubbed(:online_application, reference: existing_reference) }
    let(:online_application_url) { edit_online_application_path(online_application) }

    before do
      allow(OnlineApplication).to receive(:find_by).with(reference: existing_reference).and_return(online_application)
      allow(OnlineApplication).to receive(:find_by).with(reference: wrong_reference).and_return(nil)
    end

    context 'when reference is nil' do
      it { is_expected.to be_nil }
    end

    context 'when an online_application exists' do
      describe 'can be found using various input formats of the reference number' do
        [
          'HWF-123-ABC',
          'HWF 123 ABC',
          'HWF123ABC',
          '123-ABC',
          '123 ABC',
          'hwf-123-abc',
          '123-abc',
          '123 abc'
        ].each do |format|
          context "for '#{format}' format" do
            let(:reference) { format }

            it { is_expected.to eql online_application_url }
          end
        end
      end
    end

    context 'when an application has been processed in my office' do
      let(:reference) { existing_reference }
      let(:application) { build_stubbed(:application, reference: online_application.reference, office: user.office) }

      before do
        allow(Application).to receive(:find_by).with(reference: online_application.reference).and_return(application)
        service.online
      end

      it { is_expected.to be_nil }

      it 'sets the correct error message' do
        expect(service.error_message).to include('view application')
      end
    end

    context 'when an application has a dwp pending check' do
      let(:reference) { existing_reference }
      let(:application) { build_stubbed(:application, reference: online_application.reference, office: user.office) }

      before do
        allow(Application).to receive(:find_by).with(reference: online_application.reference).and_return(application)
        allow(application).to receive(:failed_because_dwp_error?).and_return true
        service.online
      end

      it { is_expected.to eql online_application_url }

      it 'sets the correct error message' do
        expect(service.error_message).to be_nil
      end
    end

    context 'when an application has been processed by a different office' do
      let(:office) { create(:office) }
      let(:reference) { existing_reference }
      let(:application) { build_stubbed(:application, reference: online_application.reference, office: office) }

      before do
        allow(Application).to receive(:find_by).with(reference: online_application.reference).and_return(application)
        service.online
      end

      it { is_expected.to be_nil }

      it 'sets the correct error message' do
        expect(service.error_message).to include(office.name)
      end
    end

    context 'when the reference is not there' do
      let(:reference) { wrong_reference }

      before { service.online }

      it { is_expected.to be_nil }

      it 'sets the correct error message' do
        expect(service.error_message).to eq 'Reference number is not recognised'
      end
    end

    context 'when the application has been submitted with invalid data' do
      let(:reference) { existing_reference }
      let(:invalid_online_application) { build_stubbed(:online_application, :invalid_income, reference: existing_reference) }

      before do
        allow(OnlineApplication).to receive(:find_by).with(reference: existing_reference).and_return(invalid_online_application)
        service.online
      end

      it { is_expected.to be_nil }

      it 'sets the correct error message' do
        expect(service.error_message).to eq(I18n.t('activemodel.errors.models.forms/search.attributes.reference.income_error'))
      end
    end
  end
end
