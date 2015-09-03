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

  let(:new_application_content) do
    ["You'll need:",
     "the 'Help with fees' application",
     'the court or tribunal form',
     'Start']
  end

  def login_and_visit_dashboard_as(a_user)
    login_as a_user
    visit dashboard_path
    expect(page).to have_text 'Dashboard'
  end

  def sections_present
    section_titles.each { |title| expect(page).to have_text title }
    new_application_content.each { |content| expect(page).to have_text content }
  end

  def sections_absent
    section_titles.each { |title| expect(page).not_to have_text title }
    new_application_content.each { |content| expect(page).not_to have_text content }
  end

  context 'regular user' do
    before { login_and_visit_dashboard_as user }

    it 'dashboard content' do
      sections_present
    end
  end

  context 'manager' do
    before { login_and_visit_dashboard_as manager }

    it 'dashboard content' do
      sections_present
    end
  end

  context 'admin' do
    before { login_and_visit_dashboard_as admin }

    it "doesn't have dashboard sections" do
      sections_absent
    end
  end
end
