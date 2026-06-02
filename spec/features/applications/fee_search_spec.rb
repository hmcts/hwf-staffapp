# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Fee search on application details page' do
  include Warden::Test::Helpers

  Warden.test_mode!

  let!(:jurisdictions) { create_list(:jurisdiction, 3) }
  let!(:office) { create(:office, jurisdictions: jurisdictions) }
  let!(:user) { create(:user, jurisdiction_id: jurisdictions[1].id, office: office) }
  let(:dob) { Time.zone.today - 25.years }

  before do
    allow(Settings).to receive(:freg_enabled).and_return(true)
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

  scenario 'renders the fee search field and the fee input' do
    aggregate_failures do
      expect(page).to have_field('fee_search')
      expect(page).to have_field('application_fee')
    end
  end
end
