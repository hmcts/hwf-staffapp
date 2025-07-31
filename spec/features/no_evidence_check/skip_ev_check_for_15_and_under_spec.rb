require 'rails_helper'

RSpec.feature 'Skip evidence check for 15 and under' do

  include Warden::Test::Helpers

  Warden.test_mode!

  let(:user) { create(:user) }

  before do
    dwp_api_response ''
    login_as user
    create(:application_full_remission_ev)
    create_list(:application_part_remission, 9)
  end

  scenario "If the applicant is under 15, 'Applicant over 16' is displayed on the Summary page" do
    start_new_application

    fill_personal_details_under_16('SN123456D')
    fill_application_details
    fill_saving_and_investment
    fill_benefits(false)
    fill_income(false)

    expect(page).to have_content('Applicant over 16No')
    click_button 'Complete processing'
    expect(page).to have_content('✓ Eligible for help with fees')
  end

  scenario "If the applicant is under 16 and then over" do
    start_new_application

    fill_personal_details_under_16('SN123456D')
    fill_application_details
    fill_saving_and_investment
    fill_benefits(false)
    fill_income(false)

    expect(page).to have_content('Applicant over 16No')
    click_link "ChangeDate of birth"

    fill_personal_details
    fill_application_details
    fill_saving_and_investment
    fill_benefits(false)
    fill_income(false)

    expect(page).to have_content('Applicant over 16Yes')
    click_button 'Complete processing'

    expect(page).to have_content('For HMRC income checking')
    expect(page).to have_no_content('✓ Eligible for help with fees')
  end

  scenario "If the applicant is over 16, 'Applicant over 16' is displayed on the Summary page" do
    start_new_application

    fill_personal_details
    fill_application_details
    fill_saving_and_investment
    fill_benefits(false)
    fill_income(false)

    expect(page).to have_content('Applicant over 16Yes')
    click_button 'Complete processing'

    expect(page).to have_content('For HMRC income checking')
    expect(page).to have_no_content('✓ Eligible for help with fees')
  end
end
