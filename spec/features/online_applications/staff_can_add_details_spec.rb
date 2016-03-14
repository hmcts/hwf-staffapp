require 'rails_helper'

RSpec.feature 'Staff can search for online application', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:jurisdictions) { create_list :jurisdiction, 4 }
  let(:office) { create :office, jurisdictions: jurisdictions }
  let(:user) { create :staff, office: office }

  before do
    login_as user
  end

  let(:online_application) { create :online_application, :with_reference }

  scenario 'User fills in all required fields and the application is saved' do
    given_user_is_editting_the_application
    when_they_fill_in_all_required_fields
    then_the_application_is_saved
  end

  scenario 'User does not fill in all the required fields and the application fails to save' do
    given_user_is_editting_the_application
    when_they_do_not_fill_in_all_required_fields
    then_the_application_fails_to_save
  end

  def given_user_is_editting_the_application
    visit "/online_applications/#{online_application.id}/edit"
  end

  def when_they_fill_in_all_required_fields
    fill_in :online_application_fee, with: '200'
    choose "online_application_jurisdiction_id_#{jurisdictions.first.id}"
    fill_in :online_application_form_name, with: 'E45'
    check :online_application_emergency
    fill_in :online_application_emergency_reason, with: 'EMERGENCY REASON'
    click_button 'Next'
  end

  def then_the_application_is_saved
    expect(page).to have_content 'Application has been saved.'
  end

  def when_they_do_not_fill_in_all_required_fields
    click_button 'Next'
  end

  def then_the_application_fails_to_save
    expect(page).to have_content 'Enter the fee'
    expect(page).to have_content 'You must select a jurisdiction'
  end
end
