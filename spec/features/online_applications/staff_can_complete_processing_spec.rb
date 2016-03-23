require 'rails_helper'

RSpec.feature 'Staff can complete processing of an online application', type: :feature do
  include Warden::Test::Helpers
  Warden.test_mode!

  let(:threshold_exceeded) { create :online_application, :with_reference, :threshold_exceeded, :completed, jurisdiction: user.office.jurisdictions.first }
  let(:benefit_based) { create :online_application, :with_reference, :benefits, :completed, jurisdiction: user.office.jurisdictions.first }
  let(:income_based_none) { create :online_application, :with_reference, :income, :completed, income: 5000, jurisdiction: user.office.jurisdictions.first }
  let(:income_based_part) { create :online_application, :with_reference, :income, :completed, income: 1300, jurisdiction: user.office.jurisdictions.first }
  let(:income_based_full) { create :online_application, :with_reference, :income, :completed, income: 600, jurisdiction: user.office.jurisdictions.first }

  let(:user) { create :staff }

  before do
    login_as user
  end

  scenario 'The online application has exceeded savings threshold' do
    given_user_wants_to_complete_application_with_exceeded_savings_threshold
    when_they_complete_processing
    then_they_get_failed_savings_outcome
  end

  scenario 'The online application is benefit based and DWP says the applicant is on benefits' do
    given_user_wants_to_complete_benefit_based_application_with_dwp_yes_response
    when_they_complete_processing
    then_they_get_successful_benefit_based_outcome
  end

  scenario 'The online application is benefit based and DWP says the applicant is not on benefits' do
    given_user_wants_to_complete_benefit_based_application_with_dwp_no_response
    when_they_complete_processing
    then_they_get_failed_benefit_based_outcome
  end

  scenario 'The online application is income based with too much income' do
    given_user_wants_to_complete_income_based_application_with_too_much_income
    when_they_complete_processing
    then_they_get_failed_income_outcome
  end

  scenario 'The online application is income based with part payment result' do
    given_user_wants_to_complete_income_based_application_with_income_for_part_payment
    when_they_complete_processing
    then_they_get_part_payment_income_outcome
  end

  scenario 'The online application is income based with successful outcome' do
    given_user_wants_to_complete_income_based_application_with_low_income
    when_they_complete_processing
    then_they_get_successful_income_outcome
  end

  def given_user_wants_to_complete_income_based_application_with_low_income
    visit "/online_applications/#{income_based_full.id}"
  end

  def given_user_wants_to_complete_income_based_application_with_income_for_part_payment
    visit "/online_applications/#{income_based_part.id}"
  end

  def given_user_wants_to_complete_income_based_application_with_too_much_income
    visit "/online_applications/#{income_based_none.id}"
  end

  def given_user_wants_to_complete_application_with_exceeded_savings_threshold
    visit "/online_applications/#{threshold_exceeded.id}"
  end

  def given_user_wants_to_complete_benefit_based_application_with_dwp_yes_response
    dwp_api_response('Yes', 200)
    visit "/online_applications/#{benefit_based.id}"
  end

  def given_user_wants_to_complete_benefit_based_application_with_dwp_no_response
    dwp_api_response('No', 200)
    visit "/online_applications/#{benefit_based.id}"
  end

  def when_they_complete_processing
    click_link_or_button 'Complete processing'
  end

  def then_they_get_successful_benefit_based_outcome
    expect(page).to have_content('Benefits✓ Passed')
    expect(page).to have_content('Eligible for help with fees')
  end

  def then_they_get_failed_benefit_based_outcome
    expect(page).to have_content('Benefits✗ Failed')
    expect(page).to have_content('Not eligible for help with fees')
  end

  def then_they_get_failed_savings_outcome
    expect(page).to have_content('Not eligible for help with fees')
  end

  def then_they_get_failed_income_outcome
    expect(page).to have_content('Income✗ Failed')
    expect(page).to have_content('Not eligible for help with fees')
  end

  def then_they_get_part_payment_income_outcome
    expect(page).to have_content('IncomeWaiting for part-payment')
    expect(page).to have_content('The applicant must pay £105 towards the fee')
  end

  def then_they_get_successful_income_outcome
    expect(page).to have_content('Income✓ Passed')
    expect(page).to have_content('Eligible for help with fees')
  end
end
