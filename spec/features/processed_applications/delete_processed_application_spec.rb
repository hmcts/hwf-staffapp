require 'rails_helper'

RSpec.feature 'Delete processed applications', type: :feature do
  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user }

  before do
    login_as(user)
  end

  let!(:application1) { create :application_full_remission, :processed_state, office: user.office }
  let!(:application2) { create :application_part_remission, :processed_state, office: user.office }
  let!(:application3) { create :application_part_remission }

  describe 'User deletes application' do
    before do
      visit '/processed_applications'

      click_link application1.applicant.full_name
    end

    scenario 'With reason provided the application is deleted and does not show in the list' do
      fill_in 'application_deleted_reason', with: 'Reason'
      click_button 'Delete application'

      expect(page).to have_content('Processed applications')
      expect(page).to have_content('The application has been deleted')
      within 'table.processed-applications tbody' do
        expect(page).to have_no_content(application1.applicant.full_name)
        expect(page).to have_content(application2.applicant.full_name)
      end
    end

    scenario 'With reason not provided the application shows an error' do
      click_button 'Delete application'

      expect(page).to have_content('Processed application')
      expect(page).to have_content("Full name#{application1.applicant.full_name}")
      within '.delete-form' do
        expect(page).to have_content('Enter the reason')
      end
    end
  end
end
