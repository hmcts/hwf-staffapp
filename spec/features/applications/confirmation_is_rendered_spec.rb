require 'rails_helper'

RSpec.feature 'Confirmation page', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:office) { create(:office) }
  let(:user) { create :user, office: office }

  context 'as a signed in user', js: true do
    before do
      Capybara.current_driver = :webkit
      dwp_api_response 'Yes'
      login_as user
    end

    after { Capybara.use_default_driver }

    context 'by default' do
      let(:application) { create(:application, :confirm, office: office) }

      before { visit application_confirmation_path(application) }

      scenario 'the reference number is always displayed' do
        expect(page).to have_content application.reference
      end

      scenario 'the remission register right hand guidance is no longer shown' do
        expect(page).to have_no_content 'remission register'
      end
    end

    context 'after user continues from summary' do
      let(:application) { create(:application, :confirm, office: office) }

      before { visit application_confirmation_path(application) }

      scenario 'the correct view is rendered' do
        expect(page).to have_xpath('//div[contains(@class,"callout")]/h3[@class="heading-large"]')
      end

      scenario 'the next button is rendered' do
        expect(page).to have_link('Back to start')
      end
    end

    context 'when application ends with part payment' do
      let!(:part_payment) { create(:part_payment, application: application) }
      let!(:application) { create :application_part_remission, :waiting_for_part_payment_state, office: office }

      before { visit application_confirmation_path(application) }

      scenario 'the income label displays correctly' do
        expect(page).to have_xpath('//div[contains(@class,"summary-result") and contains(@class,"part")]', text: 'Waiting for part-payment')
      end

      scenario 'the grant help with fees form is not rendered' do
        expect(page).to have_no_content 'Grant help with fees'
      end
    end

    context 'when application requires evidence' do
      let(:application) { create :application_part_remission, :waiting_for_evidence_state, office: office }

      before { visit application_confirmation_path(application) }

      scenario 'the income label displays correctly' do
        expect(page).to have_xpath('//div[contains(@class,"summary-result") and contains(@class,"part")]', text: 'Waiting for evidence')
      end

      scenario 'the grant help with fees form is not rendered' do
        expect(page).to have_no_content 'Grant help with fees'
      end
    end

    context 'when application fails because of income' do
      let(:application) { create :application_no_remission, :processed_state, office: office }

      before { visit application_confirmation_path(application) }

      scenario 'the income label displays correctly' do
        expect(page).to have_content '✗ Not eligible for help with fees'
      end

      scenario 'the grant help with fees form is not rendered' do
        expect(page).to have_no_content 'Grant help with fees'
      end
    end

    context 'when application fails because of benefits' do
      let(:application) { create :application_no_remission, :processed_state, application_type: 'benefit', office: office }

      before { visit application_confirmation_path(application) }

      scenario 'the income label displays correctly' do
        expect(page).to have_content '✗ Not eligible for help with fees'
      end

      scenario 'the grant help with fees form is rendered' do
        expect(page).to have_content 'Grant help with fees'
      end
    end

    context 'when an application has been overridden' do
      let(:application) { create(:application, :confirm, office: office) }
      let(:decision_override) { create :decision_override, application: application }

      before { visit application_confirmation_path(decision_override.application) }

      scenario 'the grant help with fees form is not rendered' do
        expect(page).to have_no_content 'Grant help with fees'
        expect(page).to have_content 'Granted help with fees'
      end
    end
  end
end
