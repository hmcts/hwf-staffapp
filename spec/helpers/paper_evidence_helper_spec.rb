require 'rails_helper'

RSpec.describe PaperEvidenceHelper, type: :helper do

  let(:application) { build_stubbed :application, detail: detail }
  let(:detail) { build_stubbed :detail, discretion_applied: nil }

  subject(:template) { helper.error_message_partial(application) }

  before do
    allow(BenefitCheckRunner).to receive_message_chain(:new, :benefit_check_date_valid?).and_return benefit_check
  end

  describe '#error_message_partial' do
    context 'when benefit_check_date is not valid' do
      let(:benefit_check) { false }

      it "return out of time template name" do
        expect(template).to eql('out_of_time')
      end

      context 'discretion granted' do
        let(:detail) { build_stubbed :detail, discretion_applied: true }

        it "return nil" do
          allow(helper).to receive(:last_benefit_check_result).and_return 'no'
          expect(template).to be_nil
        end
      end

      context 'discretion denied' do
        let(:detail) { build_stubbed :detail, discretion_applied: false }

        it "return nil" do
          allow(helper).to receive(:last_benefit_check_result).and_return 'no'
          expect(template).to be_nil
        end
      end
    end

    context 'when benefit_check_date is valid' do
      let(:benefit_check) { true }

      context 'missing_details template' do
        it "when nil" do
          allow(helper).to receive(:last_benefit_check_result).and_return nil
          expect(template).to eql('missing_details')
        end

        it "when undetermined" do
          allow(helper).to receive(:last_benefit_check_result).and_return 'undetermined'
          expect(template).to eql('missing_details')
        end
      end

      context 'technical_error template' do
        it "when server unavailable" do
          allow(helper).to receive(:last_benefit_check_result).and_return 'server unavailable'
          expect(template).to eql('technical_error')
        end

        it "when unspecified error" do
          allow(helper).to receive(:last_benefit_check_result).and_return 'unspecified error'
          expect(template).to eql('technical_error')
        end
      end
    end
  end
end
