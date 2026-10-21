require 'rails_helper'

RSpec.feature 'Online application check details - UK postcode' do
  include Warden::Test::Helpers

  Warden.test_mode!

  let(:jurisdiction) { create(:jurisdiction) }
  let(:office) { create(:office, jurisdictions: [jurisdiction]) }
  let(:user) { create(:user, office: office) }
  let(:online_application) do
    create(:online_application, :completed, :with_reference, postcode: 'SW1H 9AJ', calculation_scheme: scheme)
  end

  before do
    login_as user
    visit online_application_path(online_application)
  end

  context 'post-UCD scheme' do
    let(:scheme) { FeatureSwitching::CALCULATION_SCHEMAS[1] }

    scenario 'shows the postcode row' do
      expect(page).to have_css('.govuk-summary-list__key', text: 'UK postcode')
      expect(page).to have_css('.govuk-summary-list__value', text: 'SW1H 9AJ')
    end
  end

  context 'pre-UCD scheme' do
    let(:scheme) { FeatureSwitching::CALCULATION_SCHEMAS[0] }

    scenario 'shows the postcode row' do
      expect(page).to have_css('.govuk-summary-list__key', text: 'UK postcode')
      expect(page).to have_css('.govuk-summary-list__value', text: 'SW1H 9AJ')
    end
  end

  context 'after completing processing' do
    let(:scheme) { nil }
    let(:online_application) do
      create(:online_application, :completed, :with_reference, :income,
             income: 600, postcode: 'SW1H 9AJ', jurisdiction: jurisdiction)
    end

    scenario 'the processed page shows the postcode copied to the applicant' do
      click_button 'Complete processing'
      application = Application.find_by(online_application: online_application)

      expect(application.applicant.postcode).to eq 'SW1H 9AJ'

      visit processed_application_path(application)
      expect(page).to have_css('.govuk-summary-list__key', text: 'UK postcode')
      expect(page).to have_css('.govuk-summary-list__value', text: 'SW1H 9AJ')
    end
  end
end
