require 'rails_helper'

RSpec.feature 'User management,' do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:admin_user)    { create(:admin_user) }
  let!(:offices)      { create(:office, name: 'Bristol') }
  let(:user_invite_mailer) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }

  context 'Admin user' do
    before {
      allow(NotifyMailer).to receive_messages(user_invite: user_invite_mailer)
    }
    scenario 'invites a user' do

      new_email = 'test@digital.justice.gov.uk'
      new_name = 'Test'
      login_as(admin_user, scope: :user)
      visit new_user_invitation_path

      fill_in 'user_email', with: new_email
      fill_in 'user_name', with: new_name
      select('User', from: 'user_role')
      select('Bristol', from: 'user_office_id')

      click_button 'Send an invitation'

      expect(page).to have_xpath('//a', text: new_name)
      expect(page).to have_xpath('//td', text: offices.name)
    end

    context 'when inviting user that has been deleted' do
      let!(:deleted_user) { create(:deleted_user) }

      before do
        login_as(admin_user, scope: :user)
        visit new_user_invitation_path

        fill_in 'user_email', with: deleted_user.email
        fill_in 'user_name', with: deleted_user.name
        select('User', from: 'user_role')
        select('Bristol', from: 'user_office_id')

        click_button 'Send an invitation'
      end

      scenario 'the deleted user warning is shown' do
        expect(page).to have_content('That user has previously been deleted')
      end
    end
  end
end
