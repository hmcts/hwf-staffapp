require 'rails_helper'

RSpec.feature 'User profile', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user, office: create(:office) }

  context 'as a user' do
    scenario 'view their profile' do
      login_as user
      visit '/'
      top_right_corner = "//nav/section/ul[@class='right']/li/div[@class='inline']/a[1]"
      expect(page).to have_xpath(top_right_corner, text: "#{user.name}")
    end
  end
end
