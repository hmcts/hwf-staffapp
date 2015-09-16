require 'rails_helper'

RSpec.feature 'Confirmation page', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user, office: create(:office) }
  let(:application) { create(:application_confirm) }

  context 'as a signed in user', js: true do
    before do
      WebMock.disable_net_connect!(allow: ['127.0.0.1', 'codeclimate.com', 'www.google.com/jsapi'])
      Capybara.current_driver = :webkit
      dwp_api_response 'Yes'
      login_as user
    end

    after { Capybara.use_default_driver }

    context 'after user continues from summary' do
      before do
        visit application_build_path(application_id: application.id, id: 'confirmation')
      end

      scenario 'the correct view is rendered' do
        expect(page).to have_xpath('//h2', text: 'Application processed')
        expect(page).to have_xpath('//div[contains(@class,"callout")]/h3[@class="bold"]')
      end

      scenario 'the next button is rendered' do
        expect(page).to have_xpath('//input[@type="submit"]')
      end
    end
  end
end
