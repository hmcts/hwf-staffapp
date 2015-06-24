require 'rails_helper'

RSpec.feature 'User profile', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user, office: create(:office) }

  context 'as a user' do

    before(:each) do
      login_as user
      visit '/'
    end

    scenario 'link to their profile' do
      top_right_corner = "//nav/section/ul[@class='right']/li/div[@class='inline']/a[1]"
      expect(page).to have_xpath(top_right_corner, text: "#{user.name}")
    end

    scenario 'view their profile' do
      click_link "#{user.name}"
      expect(page).to have_text 'User details'
      expect(page).to have_text "#{user.email}"
    end

    scenario 'edit their profile' do
      visit edit_user_path user.id
      expect(page).to have_text 'Edit user'
    end
  end
end
