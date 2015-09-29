require 'rails_helper'

RSpec.feature 'While filling in the application details', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let!(:jurisdictions) { create_list :jurisdiction, 3 }
  let!(:office) { create(:office, jurisdictions: jurisdictions) }
  let!(:user) { create(:user, office: office) }

  before do
    WebMock.disable_net_connect!(allow: ['127.0.0.1', 'codeclimate.com', 'www.google.com/jsapi'])
    Capybara.current_driver = :webkit
    Capybara.page.driver.allow_url('http://www.google.com/jsapi')
  end

  after { Capybara.use_default_driver }

  context 'as a signed in user does not pick a jurisdiction', js: true do
    before { login_as user }

    context 'after completing the personal details page' do
      before do
        visit applications_new_path

        fill_in 'application_last_name', with: 'Smith'
        fill_in 'application_date_of_birth', with: Time.zone.today - 25.years
        fill_in 'application_ni_number', with: 'AB123456A'
        choose 'application_married_false'
        click_button 'Next'
      end

      scenario 'application details is shown' do
        expect(page).to have_xpath('//h2', text: 'Application details')
      end

      context 'when only the jurisdiction is selected' do
        scenario "and the form resubmitted, jurisdiction selection is not shown" do
          find(:xpath, '(//input[starts-with(@id,"application_jurisdiction_id_")])[1]').click
          click_button 'Next'
          expect(page).to have_xpath('//h2', text: 'Application details')
          fill_in 'application_fee', with: '300'
          fill_in 'application_date_received', with: Time.zone.today - 3.days
          click_button 'Next'
          expect(page).to have_content "can't be blank"
          # TODO: the bug manifests here if we resubmit the form, the
          # selection for the Jurisdiction is gone!
        end
      end
    end
  end
end
