require 'rails_helper'

RSpec.feature 'Admin can manage message info', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let!(:office) { create :office }
  let(:admin) { create :admin_user, office: office }
  let(:manager) { create :manager, office: office }

  context 'admin' do
    before { login_as admin }

    scenario 'can edit and view the message' do
      visit '/'
      click_link 'Edit banner'
      fill_in 'notification_message', with: 'This is message from admin, hear, hear.'
      check 'Show on admin homepage'
      click_button 'Save changes'
      expect(page).to have_content 'Your changes have been saved'
      visit '/'
      expect(page).to have_content 'This is message from admin, hear, hear.'
    end
  end

  context 'manager' do
    before do
      create :notification, message: 'This is message from admin, hear, hear.', show: true
      login_as manager
    end

    scenario 'can view the message' do
      visit '/'
      expect(page).not_to have_content 'Edit banner'
      expect(page).to have_content 'This is message from admin, hear, hear.'
    end
  end

  context 'befor log in' do
    before do
      create :notification, message: 'This is message from admin, hear, hear.', show: true
    end

    scenario 'can view the message' do
      visit '/'
      expect(page).to have_content 'You need to sign in before continuing.'
      expect(page).to have_content 'This is message from admin, hear, hear.'
    end
  end
end
