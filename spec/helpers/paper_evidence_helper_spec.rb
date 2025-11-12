require 'rails_helper'

RSpec.describe PaperEvidenceHelper do

  subject(:template) { helper.error_message_partial(application) }

  let(:application) { build_stubbed(:application, detail: detail) }
  let(:detail) { build_stubbed(:detail, discretion_applied: nil) }
  let(:benefit_check_runner) { instance_double(BenefitCheckRunner, can_run?: valid_data) }
  let(:valid_data) { true }

  before do
    allow(BenefitCheckRunner).to receive(:new).and_return benefit_check_runner
  end

  describe '#error_message_partial' do
    context 'can run check?' do
      let(:valid_data) { false }

      it "missing data template" do
        expect(template).to eql('missing_details')
      end
    end

    context 'when benefit_check is not valid' do
      let(:benefit_check) { false }

      it "return out of time template name" do
        expect(template).to eql('technical_error')
      end

      context 'when dwp_result is not Yes but' do
        before { allow(application).to receive(:last_benefit_check).and_return last_benefit_check }
        let(:last_benefit_check) { instance_double(BenefitCheck, dwp_result: dwp_result) }

        context 'No' do
          let(:dwp_result) { 'No' }
          it { expect(template).to eql('no_record') }
        end

        context 'Bad Request' do
          let(:dwp_result) { 'badrequest' }
          it { expect(template).to eql('technical_error') }
        end

        context 'Undetermined' do
          let(:dwp_result) { 'undetermined' }
          it { expect(template).to eql('no_record') }
        end

        context 'Deceased' do
          let(:dwp_result) { 'deceased' }
          it { expect(template).to eql('no_record') }
        end

        context 'Deleted' do
          let(:dwp_result) { 'deleted' }
          it { expect(template).to eql('no_record') }
        end

        context 'Duperseded' do
          let(:dwp_result) { 'superseded' }
          it { expect(template).to eql('no_record') }
        end

        context 'Technical fault' do
          let(:dwp_result) { 'technical fault' }
          it { expect(template).to eql('technical_error') }
        end
      end

      context 'discretion granted' do
        let(:detail) { build_stubbed(:detail, discretion_applied: true) }

        it "when result was no return nil" do
          allow(helper).to receive(:last_benefit_check_result).and_return 'no'
          expect(template).to be_nil
        end

        it "when last_benefit_check_result was invalid return nil" do
          allow(helper).to receive(:last_benefit_check_result).and_return nil
          expect(template).to be_nil
        end
      end

      context 'discretion denied' do
        let(:detail) { build_stubbed(:detail, discretion_applied: false) }

        it "return nil" do
          allow(helper).to receive(:last_benefit_check_result).and_return ''
          expect(template).to be_nil
        end
      end
    end

    context 'when benefit_check_date is valid' do
      let(:benefit_check) { true }
      let(:outcome) { 'undetermined' }
      let(:last_benefit_check) { instance_double(BenefitCheck, dwp_result: outcome) }

      context 'missing_details template' do
        it "when nil" do
          allow(application).to receive(:last_benefit_check).and_return nil
          expect(template).to eql('technical_error')
        end

        it "when undetermined" do
          allow(application).to receive(:last_benefit_check).and_return last_benefit_check
          allow(helper).to receive(:last_benefit_check_result).and_return 'undetermined'
          expect(template).to eql('no_record')
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

      context 'no_record template' do
        let(:outcome) { 'No' }

        it "when No dwp_result" do
          allow(application).to receive(:last_benefit_check).and_return last_benefit_check
          allow(helper).to receive(:last_benefit_check_result).and_return 'no'
          expect(template).to eql('no_record')
        end
      end

    end
  end
end
