require 'rails_helper'

RSpec.feature 'Dashboard', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user)    { create :user, office: create(:office) }
  let(:manager) { create :manager }
  let(:admin)   { create :admin_user }

  let(:section_titles) do
    ['New application',
     'Processed applications',
     'Get help',
     'Awaiting evidence',
     'Awaiting payment']
  end

  def login_and_visit_dashboard_as(a_user)
    login_as a_user
    visit dashboard_path
    expect(page).to have_text 'Dashboard'
  end

  context 'regular user' do
    scenario 'shows the dashboard content' do

      login_and_visit_dashboard_as user

      section_titles.each { |title| expect(page).to have_text title }
    end
  end

  context 'manager' do
    scenario 'shows the dashboard content' do

      login_and_visit_dashboard_as manager

      section_titles.each { |title| expect(page).to have_text title }
    end
  end

  context 'admin' do
    scenario "doesn't show the same view as for users & managers" do

      login_and_visit_dashboard_as admin

      section_titles.each { |title| expect(page).not_to have_text title }
    end
  end
end
