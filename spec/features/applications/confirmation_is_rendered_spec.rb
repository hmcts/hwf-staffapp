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
      json = '{"original_client_ref": "unique", "benefit_checker_status": "Yes",
                  "confirmation_ref": "T1426267181940",
                  "@xmlns": "https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check"}'
      stub_request(:post, "#{ENV['DWP_API_PROXY']}/api/benefit_checks").with(body:
      {
        birth_date: application.date_of_birth.strftime('%Y%m%d'),
        entitlement_check_date: application.date_received.strftime('%Y%m%d'),
        id: "#{user.name.gsub(' ', '').downcase.truncate(27)}@#{application.created_at.strftime('%y%m%d%H%M%S')}.#{application.id}",
        ni_number: application.ni_number,
        surname: application.last_name.upcase
      }).to_return(status: 200, body: json, headers: {})
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
