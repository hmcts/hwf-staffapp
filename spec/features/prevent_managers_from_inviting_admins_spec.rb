require 'rails_helper'

RSpec.feature 'Insecure admin invitation,', type: :feature do

  before { Capybara.current_driver = :webkit }
  after { Capybara.use_default_driver }

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:manager_user) { create :manager }
  let!(:offices) { create :office, name: 'Bristol' }
  let!(:user) { create :user }

  context 'Manager user' do
    scenario 'invites an admin' do

      new_email = 'test@digital.justice.gov.uk'
      new_name = 'Test'
      login_as(manager_user, scope: :user)
      visit new_user_invitation_path

      # save_and_open_page

      fill_in 'user_email', with: new_email
      fill_in 'user_name', with: new_name

      # within(:xpath, '//*[@id="user_role"]') { select('User') }
      within(:xpath, '//*[@id="user_role"]') do
        page.execute_script("document.getElementById('user_role').options[0].text = 'admin';")
        find(:xpath, '//*[@id="user_role"]/option[1]').set('admin')
        puts find(:xpath, '//*[@id="user_role"]/option[1]').value
        save_and_open_page
        select('admin')
      end

      click_button 'Send an invitation'

      expect(page).to have_content('Send invitation')
      expect(page).to have_content("You cannot create admin account")
    end
  end
end
