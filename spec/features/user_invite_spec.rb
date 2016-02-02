require 'rails_helper'

RSpec.feature 'User management,', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:admin_user)    { create :admin_user }
  let!(:offices)      { create :office, name: 'Bristol' }
  let!(:user)         { create :user }

  context 'Admin user' do
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

    scenario 'edits users details, but not their email address' do
      login_as admin_user
      visit edit_user_path(user.id)
      expect(page).to_not have_xpath("//input[@value='#{user.email}']")
      expect(page).to have_content "#{user.email}"
    end

    scenario 'invites a user with an invalid email address' do
      new_email = 'invalid@email.com'
      login_as(admin_user, scope: :user)
      visit new_user_invitation_path

      fill_in 'user_email', with: new_email
      fill_in 'user_name', with: 'Test name'
      select('User', from: 'user_role')
      select('Bristol', from: 'user_office_id')

      click_button 'Send an invitation'

      expect(page).to have_xpath('//div[contains(@class, "field_with_errors")]/label[@for="user_email" and @class="error"]', text: /not able to create an account with this email address/)
      expect(page).to have_xpath("//input[@value='#{new_email}']")
    end

    context 'when inviting user that has been deleted' do
      let!(:deleted_user) { create :deleted_user }

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
