require 'rails_helper'

RSpec.describe BenefitCheckBuilder do
  let(:builder) { described_class.new(application) }
  let(:online_application) { create(:online_application_with_all_details, benefits: true) }
  let(:application) { create(:application, online_application: online_application) }
  let(:online_benefit_check) { create(:online_benefit_check, :yes_result, online_application: online_application) }

  describe "build" do
    before {
      online_benefit_check
      builder
    }

    it 'creates benefit check' do
      builder.build
      expect(application.last_benefit_check).to have_attributes(
        last_name: online_benefit_check.last_name,
        date_of_birth: online_benefit_check.date_of_birth,
        ni_number: online_benefit_check.ni_number,
        date_to_check: online_benefit_check.date_to_check,
        parameter_hash: online_benefit_check.parameter_hash,
        benefits_valid: online_benefit_check.benefits_valid,
        dwp_result: online_benefit_check.dwp_result,
        error_message: online_benefit_check.error_message,
        dwp_api_token: online_benefit_check.dwp_api_token,
        our_api_token: online_benefit_check.our_api_token,
        application_id: application.id,
        user_id: application.user.id
      )
    end

    context 'full outcome' do
      let(:online_benefit_check) { create(:online_benefit_check, :yes_result, online_application: online_application) }
      before { builder.build }
      it { expect(application.outcome).to eql('full') }
      it { expect(application.application_type).to eql('benefit') }
    end

    context 'none outcome' do
      let(:online_benefit_check) { create(:online_benefit_check, :no_result, online_application: online_application) }
      before { builder.build }

      it { expect(application.outcome).to eql('none') }
      it { expect(application.application_type).to eql('benefit') }
    end

    describe 'removes online benefit check' do
      context 'if save successful' do
        before { builder.build }
        it { expect(online_application.last_benefit_check).to be_nil }
      end

      context 'if save fails' do
        let(:benefit_check) { instance_double(BenefitCheck) }
        before {
          allow(BenefitCheck).to receive(:new).and_return benefit_check
          allow(benefit_check).to receive(:save).and_return false
          builder.build
        }
        it { expect(online_application.last_benefit_check).to eq(online_benefit_check) }
      end
    end
  end
end
