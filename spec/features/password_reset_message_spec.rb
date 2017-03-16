require 'rails_helper'

RSpec.feature 'Password reset,', type: :feature do

  let(:user) { create :user }

  context 'User' do
    scenario 'reset password token expired' do
      visit edit_user_password_path(reset_password_token: 1)
      fill_in :user_password, with: '123456789'
      fill_in :user_password_confirmation, with: '123456789'
      click_button 'Update password'
      expect(page).to have_text("Your password reset link has expired. Please request a new link using the reset password function and try again.")
    end

    context 'valid token' do
      let(:token) { user.send_reset_password_instructions }

      scenario 'reset password' do
        visit edit_user_password_path(reset_password_token: token)
        fill_in :user_password, with: '123456789'
        fill_in :user_password_confirmation, with: '123456789'
        click_button 'Update password'
        expect(current_path).to eql(root_path)
        expect(page).not_to have_text("Your password reset link has expired. Please request a new link using the reset password function and try again.")
        expect(page).to have_text("Your password has been changed successfully. You are now signed in.")
      end
    end
  end
end
