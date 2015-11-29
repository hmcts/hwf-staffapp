require 'rails_helper'

RSpec.feature 'Stray error on the confirmation page', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let!(:jurisdictions) { create_list :jurisdiction, 3 }
  let!(:office) { create(:office, jurisdictions: jurisdictions) }
  let!(:user) { create(:user, office: office) }

  before do
    WebMock.disable_net_connect!(allow: ['127.0.0.1', 'codeclimate.com', 'www.google.com/jsapi'])
    Capybara.current_driver = :webkit
  end

  after { Capybara.use_default_driver }

  context 'as a user who completes the form', js: true do
    before do
      login_as user

      start_new_application

      fill_in 'application_last_name', with: 'Smith'
      fill_in 'application_date_of_birth', with: Time.zone.today - 25.years
      choose 'application_married_false'
      click_button 'Next'

      expect(page).to have_xpath('//h2', text: 'Application details')
      fill_in 'application_fee', with: '300'
      find(:xpath, '(//input[starts-with(@id,"application_jurisdiction_id_")])[1]').click
      fill_in 'application_date_received', with: Time.zone.today - 3.days
      click_button 'Next'

      expect(page).to have_xpath('//h2', text: 'Savings and investments')
      choose 'application_threshold_exceeded_true'
      click_button 'Next'

      expect(page).to have_xpath('//h2', text: 'Check details')
      click_button 'Complete processing'
    end

    context 'when on application processed page' do
      scenario "'Back to start' link redirects to home page" do
        expect(page).to have_xpath('//h2', text: 'Processing complete')
        click_link 'Back to start'
        expect(page).to have_content 'Start now'
      end
    end
  end
end
