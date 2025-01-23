require 'rails_helper'

RSpec.feature 'Password reset,' do

  let(:user) { create(:user) }
  let(:mailer) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }
  before {
    allow(NotifyMailer).to receive(:reset_password_instructions).and_return mailer
  }

  context 'User' do
    scenario 'reset password token expired' do
      visit edit_user_password_path(reset_password_token: 1)
      fill_in :user_password, with: '123456789aabb'
      fill_in :user_password_confirmation, with: '123456789aabb'
      click_button 'Update password'
      expect(page).to have_text("Your password reset link has expired. Please request a new link using the reset password function and try again.")
    end

    context 'valid token' do
      let(:token) { user.send_reset_password_instructions }

      scenario 'reset password' do
        visit edit_user_password_path(reset_password_token: token)
        fill_in :user_password, with: '123456789aabb'
        fill_in :user_password_confirmation, with: '123456789aabb'
        click_button 'Update password'
        expect(current_path).to eql(root_path)
        expect(page).to have_no_text("Your password reset link has expired. Please request a new link using the reset password function and try again.")
        expect(page).to have_text("Your password has been changed successfully. You are now signed in.")
      end
    end
  end
end
