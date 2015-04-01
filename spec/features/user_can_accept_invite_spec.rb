require 'rails_helper'

RSpec.feature 'User can accept invite', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  context 'User' do
    scenario 'can accept invitation' do
      user = FactoryGirl.create(:user)
      user.invite!

      visit accept_user_invitation_url(invitation_token: user.raw_invitation_token)

      password = 'abcdefgh'

      fill_in 'user_password', with: password
      fill_in 'user_password_confirmation', with: password

      click_button 'Set my password'

      expect(page).to have_css('h2', text: 'Dashboard', count: 1)
      expect(page).to have_css('div.alert-box.notice', count: 1)
      expect(page).to have_css('div.alert-box.notice', text: 'Your password was set successfully. You are now signed in.')
    end
  end
end
