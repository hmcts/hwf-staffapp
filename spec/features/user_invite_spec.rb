require 'rails_helper'

RSpec.feature 'Office management', :type => :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user)          { FactoryGirl.create :user }
  let(:admin_user)    { FactoryGirl.create :admin_user }

  context 'Admin user' do
    scenario 'invites a user' do

      new_email = 'test@email.com'

      login_as(admin_user, :scope => :user)
      visit new_user_invitation_path

      fill_in 'user_email', :with => new_email
      select('User', :from => 'user_role')
      click_button 'Send an invitation'

      expect(page).to have_css('a', :text => new_email, count: 1)

    end
  end
end
