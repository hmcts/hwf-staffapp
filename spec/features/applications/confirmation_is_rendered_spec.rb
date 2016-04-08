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
      let!(:application) { create :application_full_remission, :waiting_for_part_payment_state, office: office }

      before { visit application_confirmation_path(application) }

      scenario 'the income label displays correctly' do
        expect(page).to have_xpath('//div[contains(@class,"summary-result") and contains(@class,"part")]', text: 'Waiting for part-payment')
      end
    end

    context 'when application requires evidence' do
      let(:application) { create :application_part_remission, :waiting_for_evidence_state, office: office }

      before { visit application_confirmation_path(application) }

      scenario 'the income label displays correctly' do
        expect(page).to have_xpath('//div[contains(@class,"summary-result") and contains(@class,"part")]', text: 'Waiting for evidence')
      end
    end
  end
end
