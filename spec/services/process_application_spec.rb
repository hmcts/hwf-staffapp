require 'rails_helper'

RSpec.describe ProcessApplication do
  subject(:process_application) { described_class.new(application, online_application, user) }

  let(:online_application) { create(:online_application_with_all_details, benefits: true, calculation_scheme: scheme) }
  let(:application) { build(:application, online_application: online_application) }
  let(:user) { create(:user) }
  let(:scheme) { FeatureSwitching::CALCULATION_SCHEMAS[0].to_s }

  describe '#process' do
    before do
      process_application.process
    end

    context 'pre ucd' do
      it 'save applicaiton with result' do
        expect(application.id).not_to be_nil
        expect(application.outcome).to eq 'none'
      end
    end

    context 'post ucd' do
      let(:scheme) { FeatureSwitching::CALCULATION_SCHEMAS[1].to_s }
      it 'save applicaiton with result' do
        expect(application.id).not_to be_nil
        expect(application.outcome).to eq 'none'
      end
    end
  end
end
