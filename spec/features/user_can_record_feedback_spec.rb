require 'rails_helper'

RSpec.feature 'Recording feedback', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user)          { FactoryGirl.create :user, office: FactoryGirl.create(:office) }

  context 'as a user' do
    scenario 'creates a feedback record' do

      login_as user

      visit feedback_path

      fill_in 'experience', with: 'Awesome user experience!'
      fill_in 'ideas', with: 'Needs more kitten'
      choose 'feedback_rating_5'
      choose 'help_score_1'

      click_button 'Send feedback'

      expect(page).to have_xpath('//div[@class="alert-box notice"]',
        text: 'Your feedback has been recorded',
        count: 1)
    end
  end
end
