require 'rails_helper'

RSpec.feature 'New Password,' do

  let(:user) { create(:user, name: 'Jim Halpert') }

  context 'User' do
    scenario 'get new user password' do
      visit new_user_password_path
      fill_in :user_email, with: user.email
      click_button 'Get new password'
      expect(current_path).to eql(new_user_session_path)
      expect(page).to have_text("You will receive an email with instructions on how to reset your password in a few minutes.")
    end

    scenario 'invalid email' do
      visit new_user_password_path
      fill_in :user_email, with: 'test@email.com'
      click_button 'Get new password'
      expect(current_path).to eql(new_user_password_path)
      expect(page).to have_text("Email address was not found.")
    end

    scenario 'request to get new password within one minute' do
      visit new_user_password_path
      fill_in :user_email, with: user.email
      click_button 'Get new password'
      expect(current_path).to eql(new_user_session_path)
      expect(page).to have_text("You will receive an email with instructions on how to reset your password in a few minutes.")
      visit new_user_password_path
      fill_in :user_email, with: user.email
      click_button 'Get new password'
      expect(current_path).to eql(new_user_session_path)
      expect(page).to have_text("You reached the limit of password resets. Please try again in 1 minute.")
    end
  end
end
