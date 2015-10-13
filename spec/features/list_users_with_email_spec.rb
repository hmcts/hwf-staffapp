require 'rails_helper'

RSpec.feature 'User list shows emails', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:admin) { create :admin_user }
  let!(:emails) do
    (1..5).each { create :user, office: create(:office) }
    User.pluck(:email) - [admin.email]
  end

  context 'as an admin' do
    before(:each) do
      login_as admin
      visit '/users'
    end

    scenario 'email address heading' do
      expect(page).to have_content 'Email'
    end

    scenario 'there are links to email addresses' do
      emails.each do |email|
        expect(page).to have_content email
      end
    end
  end
end
