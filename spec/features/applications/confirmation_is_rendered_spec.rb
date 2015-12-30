require 'rails_helper'

RSpec.feature 'Confirmation page', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:office) { create(:office) }
  let(:user) { create :user, office: office }
  let(:application) { create(:application, :confirm, office: office) }

  context 'as a signed in user', js: true do
    before do
      Capybara.current_driver = :webkit
      dwp_api_response 'Yes'
      login_as user
    end

    after { Capybara.use_default_driver }

    context 'after user continues from summary' do
      before do
        visit application_confirmation_path(application_id: application.id)
      end

      scenario 'the correct view is rendered' do
        expect(page).to have_xpath('//h2', text: 'Processing complete')
        expect(page).to have_xpath('//div[contains(@class,"callout")]/h3[@class="bold"]')
      end

      scenario 'the next button is rendered' do
        expect(page).to have_link('Back to start')
      end
    end
  end
end
