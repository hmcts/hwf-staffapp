require 'rails_helper'

RSpec.feature 'savings and investments partner over 61 checkbox', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let!(:jurisdictions) { create_list :jurisdiction, 3 }
  let!(:office) { create(:office, jurisdictions: jurisdictions) }
  let!(:user) { create(:user, jurisdiction_id: jurisdictions[1].id, office: office) }

  before do
    Capybara.current_driver = :webkit
  end

  after { Capybara.use_default_driver }

  context 'as a signed in user with default jurisdiction', js: true do
    before do
      login_as user
      start_new_application
      fill_in 'application_last_name', with: 'Hirani'
      fill_in 'application_date_of_birth', with: '28/12/1959'
      fill_in 'application_ni_number', with: 'JL953007D'
      choose 'application_married_true'
      click_button 'Next'
      expect(page).to have_xpath('//h2', text: 'Application details')
      dwp_api_response 'Yes'
      fill_in 'application_fee', with: 50
      fill_in 'application_date_received', with: Time.zone.yesterday
      # choose jurisdiction
      find(:xpath, '(//input[starts-with(@id,"application_jurisdiction_id_")])[1]').click
      click_button 'Next'
      expect(page).to have_text 'Savings and investments'
      choose 'application_threshold_exceeded_true'
      choose 'application_partner_over_61_false'
    end

    scenario 'when the user chooses threshold not exceeded' do
      expect(page.find(:xpath, "//input[@id='application_partner_over_61_false']")['checked']).to be_truthy
    end

    context 'the user then chooses less than threshold' do
      before { choose 'application_threshold_exceeded_false' }

      scenario 'the partner over 61 options to be unchecked' do
        expect(page.find(:xpath, "//input[@id='application_partner_over_61_false']", visible: false)['checked']).to be_falsey
        expect(page.find(:xpath, "//input[@id='application_partner_over_61_true']", visible: false)['checked']).to be_falsey
      end
    end
  end
end
