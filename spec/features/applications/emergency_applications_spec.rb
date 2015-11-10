require 'rails_helper'

RSpec.feature 'Emergency application', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let!(:jurisdictions) { create_list :jurisdiction, 3 }
  let!(:office)        { create(:office, jurisdictions: jurisdictions) }
  let!(:user)          { create(:user, jurisdiction_id: jurisdictions[1].id, office: office) }
  let(:reason)         { 'A really good reason' }

  before do
    login_as user
    visit applications_new_path

    fill_in 'application_last_name', with: 'Smith'
    fill_in 'application_date_of_birth', with: Time.zone.today - 25.years
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
    let(:application) { create :application_full_remission, emergency_reason: reason }

    before { visit application_summary_path(application) }

    scenario 'there will be the reason for emergency application' do
      ['Application details',
       reason].each do |content|
        expect(page).to have_content content
      end
    end
  end
end
