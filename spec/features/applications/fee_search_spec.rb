# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Fee search on application details page', :js do
  include Warden::Test::Helpers

  Warden.test_mode!

  let!(:jurisdictions) { create_list(:jurisdiction, 3) }
  let!(:office) { create(:office, jurisdictions: jurisdictions) }
  let!(:user) { create(:user, jurisdiction_id: jurisdictions[1].id, office: office) }
  let(:dob) { Time.zone.today - 25.years }

  before do
    ApplicationHelper.fee_search_enabled = true
    login_as user
    start_new_application

    fill_in 'application_first_name', with: 'John', wait: true
    fill_in 'application_last_name', with: 'Smith', wait: true
    fill_in 'application_day_date_of_birth', with: dob.day
    fill_in 'application_month_date_of_birth', with: dob.month
    fill_in 'application_year_date_of_birth', with: dob.year
    fill_in 'application_ni_number', with: 'AB123456A'
    choose 'application_married_false'
    click_button 'Next'
  end

  after do
    ApplicationHelper.fee_search_enabled = nil
  end

  scenario 'searching for a fee code displays results and fills in the fee' do
    expect(page).to have_field('fee_search')

    fill_in 'fee_search', with: 'FEE0001'
    expect(page).to have_css('#fee-search-results > li', wait: 5)

    first('#fee-search-results > li').click

    expect(page).to have_field('application_fee', with: '100')
  end

  scenario 'searching with no matches shows no results message' do
    fill_in 'fee_search', with: 'NONEXISTENT'
    expect(page).to have_css('#no-results-message:not(.govuk-visually-hidden)', wait: 5)
  end
end
