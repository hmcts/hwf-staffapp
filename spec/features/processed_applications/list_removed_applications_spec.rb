require 'rails_helper'

RSpec.feature 'List removed applications', type: :feature do
  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user }

  before do
    login_as(user)
  end

  let!(:application1) { create :application_full_remission, :removed_state, office: user.office }
  let!(:application2) { create :application_part_remission, :removed_state, office: user.office }
  let!(:application3) { create :application_part_remission, :processed_state, office: user.office }

  scenario 'User lists all removed applications' do
    visit '/'

    expect(page).to have_content('Removed applications')

    within '.removed-applications' do
      click_link 'View all'
    end

    expect(page.current_path).to eql('/removed_applications')

    within 'table.removed-applications tbody' do
      expect(page).to have_content(application1.applicant.full_name)
      expect(page).to have_content(application2.applicant.full_name)
    end
  end

  scenario 'User displays detail of one removed application' do
    visit '/removed_applications'

    click_link application1.applicant.full_name

    expect(page.current_path).to eql("/removed_applications/#{application1.id}")

    expect(page).to have_content('Removed application')
    expect(page).to have_content("Full name#{application1.applicant.full_name}")
  end
end
