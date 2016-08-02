require 'rails_helper'

RSpec.feature 'User can search for online application', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:office) { create :office }
  let(:user) { create :staff, office: office }

  let(:application_processed) { create(:application_full_remission, :processed_state, office: office) }
  let(:application_deleted) { create(:application_full_remission, :deleted_state, office: office) }

  let(:application_evidence_check) { create(:application_full_remission, :waiting_for_evidence_state, office: office) }
  let!(:evidence_check) { create(:evidence_check, application: application_evidence_check) }

  let(:application_part_payment) { create(:application_part_remission, :waiting_for_part_payment_state, office: office) }
  let!(:part_payment) { create(:part_payment, application: application_part_payment) }

  before do
    login_as user
  end

  scenario 'User does not provide the reference number' do
    given_user_is_on_the_homepage
    when_they_try_to_search_without_providing_reference_number
    then_they_get_a_blank_error
  end

  scenario 'User provides a wrong reference number' do
    given_user_is_on_the_homepage
    when_they_search_for_not_existent_application
    then_they_get_a_not_found_error
  end

  scenario 'User provides a reference number for an existing processed application' do
    given_user_is_on_the_homepage
    when_they_search_for_an_existing_processed_application
    then_they_are_redirected_to_the_processed_application_page
  end

  scenario 'User provides a reference number for an existing deleted application' do
    given_user_is_on_the_homepage
    when_they_search_for_an_existing_deleted_application
    then_they_are_redirected_to_the_deleted_application_page
  end

  scenario 'User provides a reference number for an existing application waiting for evidence check' do
    given_user_is_on_the_homepage
    when_they_search_for_an_existing_application_with_evidence_check
    then_they_are_redirected_to_the_evidence_check_page
  end

  scenario 'User provides a reference number for an existing application waiting for part payment' do
    given_user_is_on_the_homepage
    when_they_search_for_an_existing_application_with_part_payment
    then_they_are_redirected_to_the_part_payment_page
  end

  def do_search(reference = nil)
    fill_in :completed_search_reference, with: reference if reference
    click_button 'Search'
  end

  def check_page(title, reference)
    expect(page).to have_text(title)
    expect(page).to have_text(reference)
  end

  def given_user_is_on_the_homepage
    visit '/'
  end

  def when_they_try_to_search_without_providing_reference_number
    do_search
  end

  def when_they_search_for_not_existent_application
    do_search('something')
  end

  def when_they_search_for_an_existing_processed_application
    do_search(application_processed.reference)
  end

  def when_they_search_for_an_existing_deleted_application
    do_search(application_deleted.reference)
  end

  def when_they_search_for_an_existing_application_with_evidence_check
    do_search(application_evidence_check.reference)
  end

  def when_they_search_for_an_existing_application_with_part_payment
    do_search(application_part_payment.reference)
  end

  def then_they_get_a_blank_error
    expect(page).to have_text('Must not be blank')
  end

  def then_they_get_a_not_found_error
    expect(page).to have_text('Application not found')
  end

  def then_they_are_redirected_to_the_processed_application_page
    check_page('Processed application', application_processed.applicant.full_name)
  end

  def then_they_are_redirected_to_the_deleted_application_page
    check_page('Deleted application', application_deleted.applicant.full_name)
  end

  def then_they_are_redirected_to_the_evidence_check_page
    check_page('Waiting for evidence', application_evidence_check.reference)
  end

  def then_they_are_redirected_to_the_part_payment_page
    check_page('Waiting for part-payment', application_part_payment.reference)
  end
end
