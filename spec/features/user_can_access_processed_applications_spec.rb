require 'rails_helper'

RSpec.feature 'User can access processed applications,', type: :feature do
  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user }

  before do
    login_as(user)
  end

  context 'when the processed application feature is enabled' do
    let!(:application1) { create :application_full_remission }
    let!(:application2) { create :application_part_remission }

    enable_processed_applications

    scenario 'User lists all processed applications' do
      visit '/'

      expect(page).to have_content('Processed applications')

      within '.processed-applications' do
        click_link 'View all'
      end

      expect(page.current_path).to eql('/processed_applications')

      within 'table.processed-applications tbody' do
        expect(page).to have_content(application1.reference)
        expect(page).to have_content(application2.reference)
      end
    end

    scenario 'User displays detail of one processed application' do
      visit '/processed_applications'

      click_link application1.reference

      expect(page.current_path).to eql("/processed_applications/#{application1.id}")

      expect(page).to have_content(application1.reference)
    end
  end

  context 'when the processed application feature is disabled' do
    disable_processed_applications

    scenario 'User can not list all processed applications' do
      visit '/'

      expect(page).to have_no_content('Processed applications')
    end
  end
end
