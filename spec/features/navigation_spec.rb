require 'rails_helper'

RSpec.feature 'Naviation links', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:office) { create :office }

  context 'User' do
    let(:user) { create :user, office: office, name: 'Johny Mnemonic' }

    scenario 'display navigation' do
      login_as(user)
      visit root_url
      within(:xpath, './/div[@class="header-proposition"]') do
        expect(page).to have_text('Welcome Johny Mnemonic')
        expect(page).to have_xpath(".//a[contains(.,'View profile')][@href='#{user_path(user)}']")
        expect(page).to have_xpath(".//a[contains(.,'Staff Guides')][@href='#{guide_path}']")
        expect(page).to have_xpath(".//a[contains(.,'Letter templates')][@href='#{letter_templates_path}']")
        expect(page).to have_xpath(".//a[contains(.,'Sign out')][@href='#{destroy_user_session_path}']")
      end
    end
  end

  context 'manager' do
    let(:manager) { create :manager, office: office, name: 'Agent Smith' }

    scenario 'display navigation' do
      login_as(manager)
      visit root_url
      within(:xpath, './/div[@class="header-proposition"]') do
        expect(page).to have_text('Welcome Agent Smith')
        expect(page).to have_xpath(".//a[contains(.,'View profile')][@href='#{user_path(manager)}']")
        expect(page).to have_xpath(".//a[contains(.,'View office')][@href='#{office_path(office)}']")
        expect(page).to have_xpath(".//a[contains(.,'View staff')][@href='#{users_path}']")
        expect(page).to have_xpath(".//a[contains(.,'Staff Guides')][@href='#{guide_path}']")
        expect(page).to have_xpath(".//a[contains(.,'Letter templates')][@href='#{letter_templates_path}']")
        expect(page).to have_xpath(".//a[contains(.,'Sign out')][@href='#{destroy_user_session_path}']")
      end
    end
  end
end
