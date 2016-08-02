require 'rails_helper'

RSpec.feature 'Staff can search for online application', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :staff }

  before do
    login_as user
  end

  let(:online_application) { create :online_application, :with_reference }

  scenario 'User does not provide the reference number' do
    given_user_is_on_the_homepage
    when_they_try_to_search_without_providing_reference_number
    then_they_get_a_blank_error
  end

  scenario 'User provides a wrong reference number' do
    given_user_is_on_the_homepage
    when_they_search_for_not_existent_online_application
    then_they_get_a_not_found_error
  end

  scenario 'User provides a reference number for an existing online application' do
    given_user_is_on_the_homepage
    when_they_search_for_an_existing_online_application
    then_they_are_redirected_to_the_application_details_page
  end

  def given_user_is_on_the_homepage
    visit '/'
  end

  def when_they_try_to_search_without_providing_reference_number
    click_button 'Look up'
  end

  def when_they_search_for_not_existent_online_application
    fill_in :online_search_reference, with: 'something'
    click_button 'Look up'
  end

  def when_they_search_for_an_existing_online_application
    fill_in :online_search_reference, with: online_application.reference
    click_button 'Look up'
  end

  def then_they_get_a_blank_error
    expect(page).to have_text('Please enter a reference number')
  end

  def then_they_get_a_not_found_error
    expect(page).to have_text('Reference number is not recognised')
  end

  def then_they_are_redirected_to_the_application_details_page
    expect(page).to have_text('Application details')
    expect(page).to have_text(online_application.last_name)
  end
end
