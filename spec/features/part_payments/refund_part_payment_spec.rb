# coding: utf-8
require 'rails_helper'

RSpec.feature 'Part Payment refund flow', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:office) { create :office }
  let(:user) { create :user, office: office }

  before { login_as user }

  describe 'paper part payment application refund' do
    scenario 'is marked as processed and not waiting for payment' do
      visit home_index_url

      within "#process-application" do
        expect(page).to have_text('Process application')
        click_link "Start now"
      end

      fill_personal_details
      fill_application_refund_details(410)
      fill_saving_and_investment
      fill_benefits(false)
      fill_income(true, 2000, 3)

      click_button 'Complete processing'
      expect(page).to have_text 'The applicant must pay £90 towards the fee'
      click_link 'Back to start'
      expect(page).to have_text 'There are no applications waiting for evidence'

      click_link "Processed applications"

      within(:xpath, './/table[contains(@class, "processed-applications")]') do
        expect(page).to have_content(reference)
      end
    end
  end

  def reference
    Application.last.reference
  end
end
