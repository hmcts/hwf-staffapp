require 'rails_helper'

RSpec.feature 'Recording and viewing feedback' do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create(:user, office: create(:office)) }
  let(:admin) { create(:admin_user, office: create(:office)) }

  context 'as a user' do
    scenario 'creates a feedback record' do

      login_as user
      visit home_index_url

      within(:xpath, './/ul[@id="navigation"]') do
        click_link 'Feedback'
      end
      expect(page).not_to have_text "Feedback received"

      fill_in 'experience', with: 'Awesome user experience!'
      fill_in 'ideas', with: 'Needs more kitten'
      choose 'feedback_rating_5'
      choose 'help_score_1'

      click_button 'Send feedback'
      expect(page).to have_xpath('//div[@class="govuk-error-summary__body"]',
                                 text: 'Your feedback has been recorded',
                                 count: 1)
    end
  end

  context 'as an admin' do
    let(:feedback) { create(:feedback, experience: 'It works fine.') }
    before { feedback }

    scenario 'read a feedback records' do
      login_as admin
      visit home_index_url

      within(:xpath, './/ul[@id="navigation"]') do
        click_link 'Feedback'
      end

      expect(page).not_to have_text "You don’t have permission to do this"
      expect(page).to have_text "Feedback received"
      expect(page).to have_text "It works fine"
    end
  end
end
