require 'rails_helper'

# The UK postcode field on the paper "Personal details" page is part of the
# DWP API work, so it is only shown when DWP_API_ENABLED is on. See CHANGELOG.md
RSpec.feature 'Personal details - UK postcode' do
  include Warden::Test::Helpers

  Warden.test_mode!

  let!(:jurisdictions) { create_list(:jurisdiction, 1) }
  let!(:office) { create(:office, jurisdictions: jurisdictions) }
  let!(:user) { create(:user, jurisdiction_id: jurisdictions.first.id, office: office) }
  let(:application) { create(:application, office: office) }

  before do
    allow(Settings).to receive(:dwp_api_enabled).and_return(dwp_api_enabled)
    login_as user
    visit application_personal_informations_path(application)
  end

  context 'when the DWP API is enabled' do
    let(:dwp_api_enabled) { true }

    scenario 'the postcode field is shown between last name and date of birth' do
      expect(page).to have_field('UK postcode')
      expect(page.body.index('application_last_name')).to be < page.body.index('application_postcode')
      expect(page.body.index('application_postcode')).to be < page.body.index('application_day_date_of_birth')
    end

    scenario 'the postcode is optional' do
      fill_personal_details(postcode: '')
      expect(page).to have_text('Application details')
      expect(application.applicant.reload.postcode).to be_nil
    end

    scenario 'a valid postcode is saved' do
      fill_personal_details(postcode: 'tw141uh')
      expect(page).to have_text('Application details')
      expect(application.applicant.reload.postcode).to eq 'TW141UH'
    end

    scenario 'the summary page shows the postcode row (post-UCD)' do
      fill_personal_details(postcode: 'TW14 1UH')
      visit application_summary_path(application)
      expect(page).to have_css('.govuk-summary-list__key', text: 'UK postcode')
      expect(page).to have_css('.govuk-summary-list__value', text: 'TW14 1UH')
    end

    scenario 'the summary page shows the postcode row (pre-UCD)' do
      application.detail.update(calculation_scheme: FeatureSwitching::CALCULATION_SCHEMAS[0])
      fill_personal_details(postcode: 'TW14 1UH')
      visit application_summary_path(application)
      expect(page).to have_css('.govuk-summary-list__key', text: 'UK postcode')
      expect(page).to have_css('.govuk-summary-list__value', text: 'TW14 1UH')
    end

    scenario 'the summary page hides the postcode row when none was entered' do
      fill_personal_details(postcode: '')
      visit application_summary_path(application)
      expect(page).to have_no_css('.govuk-summary-list__key', text: 'UK postcode')
    end

    scenario 'an invalid postcode shows the GDS error message' do
      fill_personal_details(postcode: 'not a postcode')
      expect(page).to have_text('Enter a valid UK postcode, with or without a space')
      expect(page).to have_field('UK postcode', with: 'NOT A POSTCODE')
    end
  end

  context 'when the DWP API is disabled' do
    let(:dwp_api_enabled) { false }

    scenario 'the postcode field is not shown' do
      expect(page).to have_no_field('UK postcode')
    end
  end

  def fill_personal_details(postcode:)
    dob = Time.zone.today - 25.years
    fill_in 'application_first_name', with: 'Peter'
    fill_in 'application_last_name', with: 'Smith'
    fill_in 'application_postcode', with: postcode
    fill_in 'application_day_date_of_birth', with: dob.day
    fill_in 'application_month_date_of_birth', with: dob.month
    fill_in 'application_year_date_of_birth', with: dob.year
    choose 'application_married_false'
    click_button 'Next'
  end
end
