require 'rails_helper'

# I'm disabling this Rubocop check to allow writing readable scenarios
# rubocop:disable RSpec/InstanceVariable

RSpec.feature 'Manager has to setup their office and preferences', type: :feature do

  scenario 'Signing in for second time or later and their office is not setup is redirected to office setup' do
    given_the_office_is_not_setup
    and_manager_has_signed_in_before
    when_they_sign_in
    then_they_are_redirected_to_the_office_setup
  end

  scenario 'Signing in for second time or later and their office is already setup is redirected to dashboard' do
    given_the_office_is_setup
    and_manager_has_signed_in_before
    when_they_sign_in
    then_they_are_redirected_to_the_dashboard
  end

  scenario 'Signing in for the first time is redirected to office setup' do
    given_the_office_is_not_setup
    and_manager_has_not_signed_in_before
    when_they_sign_in
    then_they_are_redirected_to_the_office_setup
  end

  scenario 'After setting up the office, they are redirected to their profile setup if signing in for the first time' do
    given_the_office_is_not_setup
    and_manager_has_not_signed_in_before
    and_they_sign_in
    when_they_setup_the_office
    then_they_are_redirected_to_the_profile_setup
  end

  scenario 'After setting up the office, they are redirected to dashboard if signing in for second time or later' do
    given_the_office_is_not_setup
    and_manager_has_signed_in_before
    and_they_sign_in
    when_they_setup_the_office
    then_they_are_redirected_to_the_dashboard
  end

  scenario 'After setting up their profile, they are redirected to dashboard if signing in for the first time' do
    given_the_office_is_not_setup
    and_manager_has_not_signed_in_before
    and_they_sign_in
    when_they_setup_the_office
    when_whey_setup_their_profile
    then_they_are_redirected_to_the_dashboard
  end

  def given_the_office_is_not_setup
    @office = create :office
  end

  def given_the_office_is_setup
    @office = create :office_with_jurisdictions
  end

  def and_manager_has_signed_in_before
    @manager = create :manager, office: @office, sign_in_count: 2
  end

  def and_manager_has_not_signed_in_before
    @manager = create :manager, office: @office, sign_in_count: 0
  end

  def when_they_sign_in
    visit new_user_session_path
    fill_in 'user_email', with: @manager.email
    fill_in 'user_password', with: @manager.password
    click_button 'Sign in'
  end
  alias_method :and_they_sign_in, :when_they_sign_in

  def when_they_setup_the_office
    check Jurisdiction.first.name
    click_button 'Update Office'
  end

  def when_whey_setup_their_profile
    choose Jurisdiction.first.name
    click_button 'Save changes'
  end

  def then_they_are_redirected_to_the_office_setup
    expect(page.current_path).to eql "/offices/#{@office.id}/edit"
  end

  def then_they_are_redirected_to_the_dashboard
    expect(page.current_path).to eql '/'
  end

  def then_they_are_redirected_to_the_profile_setup
    expect(page.current_path).to eql "/users/#{@manager.id}/edit"
  end
end
