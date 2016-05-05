require 'rails_helper'

RSpec.describe ApplicationSearch do
  let(:reference) { nil }
  let(:user) { create :staff }

  subject(:service) { described_class.new(reference, user) }

  it { is_expected.to respond_to :error_message }

  describe '#for_hwf' do
    let(:online_application) { build_stubbed(:online_application, :with_reference) }

    subject { service.for_hwf }

    before do
      allow(OnlineApplication).to receive(:find_by).with(reference: online_application.reference).and_return(online_application)
      allow(OnlineApplication).to receive(:find_by).with(reference: online_application.reference.reverse).and_return(nil)
    end

    context 'when reference is nil' do
      it { is_expected.to eq nil }
    end

    context 'when an online_application exists' do
      let(:reference) { online_application.reference }

      it { is_expected.to eql online_application }
    end

    context 'when an application has been processed in my office' do
      let(:reference) { online_application.reference }
      let(:application) { build_stubbed(:application, reference: online_application.reference, office: user.office) }

      before do
        allow(Application).to receive(:find_by).with(reference: online_application.reference).and_return(application)
        service.for_hwf
      end

      it { is_expected.to eql false }

      it 'sets the correct error message' do
        expect(service.error_message).to include('view application')
      end
    end

    context 'when an application has been processed by a different office' do
      let(:office) { create :office }
      let(:reference) { online_application.reference }
      let(:application) { build_stubbed(:application, reference: online_application.reference, office: office) }

      before do
        allow(Application).to receive(:find_by).with(reference: online_application.reference).and_return(application)
        service.for_hwf
      end

      it { is_expected.to eql false }

      it 'sets the correct error message' do
        expect(service.error_message).to include(office.name)
      end
    end

    context 'when the reference is not there' do
      let(:reference) { online_application.reference.reverse }

      before { service.for_hwf }

      it { is_expected.to be false }

      it 'sets the correct error message' do
        expect(service.error_message).to eq 'Application not found'
      end
    end
  end
end
