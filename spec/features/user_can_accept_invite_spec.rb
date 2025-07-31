require 'rails_helper'

RSpec.feature 'User can accept invite' do

  include Warden::Test::Helpers

  Warden.test_mode!

  context 'User' do
    scenario 'can accept invitation' do
      user = create(:user)
      user.invite!

      visit accept_user_invitation_url(invitation_token: user.raw_invitation_token)

      password = 'abcdefgh123456'

      fill_in 'user_password', with: password
      fill_in 'user_password_confirmation', with: password

      click_button I18n.t('devise.invitations.edit.submit_button')

      expect(page).to have_xpath('//div[@class="govuk-error-summary__body"]',
                                 text: 'Your password was set successfully. You are now signed in.',
                                 count: 1)
    end
  end
end
