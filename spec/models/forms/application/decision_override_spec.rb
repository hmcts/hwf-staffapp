require 'rails_helper'

RSpec.describe Forms::Application::DecisionOverride do
  subject(:form) { described_class.new(override) }

  params_list = %i[value reason created_by_id]

  let(:override) { build_stubbed :decision_override }
  let(:user) { create :staff }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  context 'validation' do
    subject { form.valid? }

    before { form.update_attributes(params) }

    context 'user_id' do
      let(:user_id) { nil }
      let(:params) { { value: 1, reason: nil, created_by_id: user_id } }

      context 'not set' do
        it { is_expected.to be false }
      end

      context 'set with a checkbox value' do
        let(:user_id) { user.id }

        it { is_expected.to be true }
      end

    end

    context 'with attribute "value"' do
      let(:reason) { nil }
      let(:option) { nil }
      let(:params) { { value: option, reason: reason, created_by_id: user.id } }

      context 'not set' do
        it { is_expected.to be false }
      end

      context 'set with a checkbox value' do
        let(:option) { 1 }

        it { is_expected.to be true }
      end

      context 'set with "other" value' do
        let(:option) { 'other' }

        it { is_expected.to be false }

        context 'with attribute "reason"' do

          context 'not set' do
            it { is_expected.to be false }
          end

          context 'set' do
            let(:reason) { 'Some reason' }

            it { is_expected.to be true }
          end
        end
      end
    end
  end

  describe '#application_overridable?' do

    subject { form.application_overridable?(application) }

    context 'when the form was instantiated with an application' do
      let(:outcome) { 'none' }
      let(:application) { create :application_no_remission, :processed_state, application_type: type, outcome: outcome }
      let(:form) { described_class.new(application) }

      context 'that was income based' do
        let(:type) { 'income' }

        context 'with no remission granted' do
          it { is_expected.to be true }
        end

        context 'with full remission granted' do
          let(:outcome) { 'full' }

          it { is_expected.to be false }
        end
      end

      context 'that was benefits based' do
        let(:type) { 'benefit' }

        context 'with no remission granted' do
          it { is_expected.to be true }
        end

        context 'with full remission granted' do
          let(:outcome) { 'full' }

          it { is_expected.to be false }
        end
      end
    end
  end

  describe '#save' do
    subject(:save_form) { form.save }

    let(:override) { create :decision_override }

    before do
      form.update_attributes(params)
    end

    context 'for an invalid form' do
      let(:params) { { value: nil, reason: nil, created_by_id: user.id } }
      it { is_expected.to be false }
    end

    context 'for a valid form when a value is chosen' do
      let(:params) { { value: 1, reason: nil, created_by_id: user.id } }

      it { is_expected.to be true }

      before { save_form && override.reload }

      it 'updates the reason from the option label' do
        expect(override.reason).to eql "You've received paper evidence that the applicant is receiving benefits"
      end
    end

    context 'for a valid form when user inputs a reason' do
      let(:params) { { value: 'other', reason: 'foo reason bar', created_by_id: user.id } }

      it { is_expected.to be true }

      before { save_form && override.reload }

      it 'updates the correct field on evidence check and creates reason record with explanation' do
        expect(override.reason).to eql 'foo reason bar'
      end
    end
  end

end
