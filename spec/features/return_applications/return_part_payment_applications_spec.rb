require 'rails_helper'

RSpec.feature 'When part-payment applications are returned', type: :feature do
  include Warden::Test::Helpers
  Warden.test_mode!

  let(:office) { create :office }
  let(:user) { create :user, office: office }

  let(:application1) { create :application_full_remission, office: office }
  let!(:evidence1) { create :part_payment, application: application1 }
  let(:application2) { create :application_full_remission, office: office }
  let!(:evidence2) { create :part_payment, application: application2 }

  before { login_as user }

  context 'when on home page' do

    before { visit root_path }

    scenario 'shows the applications that are waiting for part-payment' do
      within '.waiting-for-part_payment' do
        expect(page).to have_content(application1.reference)
        expect(page).to have_content(application2.reference)
      end
    end

    scenario 'shows "Start now" button' do
      click_link application1.reference
      expect(page).to have_content 'Process part-payment'
      expect(page).to have_content application1.applicant.full_name
      expect(page).to have_link 'Start now'
    end

    scenario 'when returning application' do
      click_link application1.reference
      click_link 'Start now'
      expect(page).to have_content 'Part-payment details'
      choose 'part_payment_correct_false'
      click_button 'Next'
      expect(page).to have_content 'Check details'
      click_button 'Complete processing'
      expect(page).to have_content 'Processing complete'
      click_link 'Back to start'
      expect(page).not_to have_content application1.reference
      within '.waiting-for-part_payment' do
        expect(page).not_to have_content(application1.reference)
      end
    end
  end
end
