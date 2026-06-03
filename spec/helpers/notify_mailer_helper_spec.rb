require 'rails_helper'

RSpec.describe NotifyMailerHelper do
  let(:application) { build(:online_application_with_all_details, :with_reference) }

  describe '#hash_for_personalisation' do
    let(:result) { helper.hash_for_personalisation(application) }

    it 'returns the application reference' do
      expect(result[:application_reference_code]).to eq(application.reference)
    end

    it 'pairs every populated value with a has_* flag set to "yes"' do
      expect(result[:has_application_reference_code]).to eq('yes')
    end

    context 'when a field is blank' do
      before { application.form_name = '' }

      it 'returns an empty string for the value' do
        expect(result[:application_form_name]).to eq('')
      end

      it 'sets the corresponding has_* flag to "no"' do
        expect(result[:has_application_form_name]).to eq('no')
      end
    end

    describe 'application_status' do
      context 'when married' do
        before { application.married = true }
        it { expect(result[:application_status]).to eq(I18n.t('married_true', scope: 'email.general')) }
      end

      context 'when single' do
        it { expect(result[:application_status]).to eq(I18n.t('married_false', scope: 'email.general')) }
      end
    end

    describe 'application_fee_paid' do
      context 'refund application' do
        it { expect(result[:application_fee_paid]).to eq(I18n.t('email.confirmation.true')) }
      end

      context 'non-refund application' do
        before { application.refund = false }
        it { expect(result[:application_fee_paid]).to eq(I18n.t('email.confirmation.false')) }
      end
    end

    describe 'application_children' do
      context 'when children is nil' do
        before { application.children = nil }

        # children_text returns 'N/A' which the helper post-processes to ''
        it { expect(result[:application_children]).to eq('') }
        it { expect(result[:has_application_children]).to eq('no') }
      end

      context 'when children is set' do
        it { expect(result[:application_children]).to eq(application.children) }
        it { expect(result[:has_application_children]).to eq('yes') }
      end
    end

    describe 'application_applying_method' do
      context 'when applying online' do
        before { application.applying_method = 'online' }
        it { expect(result[:application_applying_method]).to eq(I18n.t('email.confirmation.online.applying_method')) }
      end

      context 'when applying on paper' do
        before { application.applying_method = 'paper' }
        it { expect(result[:application_applying_method]).to eq(I18n.t('email.confirmation.paper.applying_method')) }
      end
    end

    describe 'income_period' do
      context 'when married' do
        before { application.income_period = '' }
        it { expect(result[:application_income_period]).to eq('') }
      end

      context 'when single' do
        it { expect(result[:application_status]).to eq(I18n.t('married_false', scope: 'email.general')) }
      end
    end

  end
end
