require 'rails_helper'

RSpec.feature 'Emergency application', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let!(:jurisdictions) { create_list :jurisdiction, 3 }
  let!(:office)        { create(:office, jurisdictions: jurisdictions) }
  let!(:user)          { create(:user, jurisdiction_id: jurisdictions[1].id, office: office) }
  let(:reason)         { 'A really good reason' }
  let(:dob)            { Time.zone.today - 25.years }

  before do
    login_as user
    start_new_application

    fill_in 'application_last_name', with: 'Smith'
    fill_in 'application_day_date_of_birth', with: dob.day
    fill_in 'application_month_date_of_birth', with: dob.month
    fill_in 'application_year_date_of_birth', with: dob.year
    fill_in 'application_ni_number', with: 'AB123456A'
    choose 'application_married_false'
    click_button 'Next'
  end

  context 'when on application details page' do
    scenario 'there will be emergency application option' do
      expect(page).to have_content 'This is an emergency case'
    end

    context 'when the emergency case option is chosen' do
      before { check 'application_emergency' }
      label_text = 'Reason for emergency'

      scenario 'there will be a way to add the explanation for emergency reason' do
        expect(page).to have_content label_text
        fill_in 'application_emergency_reason', with: reason
        expect(page).to have_field('Reason for emergency', with: reason)
      end
    end
  end

  context 'when on application summary page' do
    let(:application) { create :application_full_remission, office: office, emergency_reason: reason }

    before { visit application_summary_path(application) }

    scenario 'there will be the reason for emergency application' do
      ['Application details',
       reason].each do |content|
        expect(page).to have_content content
      end
    end
  end
end
