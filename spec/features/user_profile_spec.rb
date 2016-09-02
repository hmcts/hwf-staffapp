require 'rails_helper'

RSpec.feature 'User profile', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user, office: create(:office) }
  let(:another_user) { create :user, office: create(:office) }

  context 'as a user' do

    before(:each) do
      login_as user
      visit '/'
    end

    scenario 'link to their profile' do
      top_right_corner = '//ul[@id="proposition-links"]/li/span'
      expect(page).to have_xpath("#{top_right_corner}[contains(., '#{user.name}')]")
    end

    context 'show view' do
      scenario 'view their profile' do
        click_link 'View profile'
        ['Staff details',
         user.email,
         user.role].each { |line| expect(page).to have_text line }
      end

      scenario 'only view their own profile' do
        visit user_path(another_user.id)
        expect(page).not_to have_text another_user.email
      end
    end

    context 'password edit' do
      scenario 'allow users to change their password' do
        visit edit_user_registration_path user.id
        expect(page).to have_text 'Current password'
        expect(page).not_to have_text 'Pundit::AuthorizationNotPerformedError'
      end

      scenario 'prevent users to edit somebody elses password' do
        visit edit_user_registration_path another_user.id
        expect(page).to have_text "You don’t have permission to do this"
      end
    end

    context 'edit' do
      before(:each) { visit edit_user_path user.id }

      scenario 'their profile' do
        ['Change details',
         'Office',
         'Main jurisdiction',
         'Role'].each { |value| expect(page).to have_text value }
      end

      scenario 'their role should not be editable' do
        expect(page).not_to have_select('user[role]', options: ['User', 'Manager'])
      end
    end

    context 'update their profile' do
      let(:new_name) { 'New user name' }
      before(:each) do
        visit edit_user_path user.id
        fill_in 'user_name', with: new_name
        click_button 'Save changes'
      end

      scenario 'their name has updated' do
        expect(page).to have_text new_name
      end
    end
  end
end
