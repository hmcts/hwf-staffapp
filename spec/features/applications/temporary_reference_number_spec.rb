require 'rails_helper'

RSpec.feature 'Reference number is displayed', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user, office: create(:office) }
  let(:application) { create(:application, :confirm, reference: 'AB123-14-0001') }

  context 'before the set reference_date is reached' do
    context 'as a signed in user', js: true do
      before do
        Capybara.current_driver = :webkit
        dwp_api_response 'Yes'
        login_as user
      end

      after { Capybara.use_default_driver }

      context 'after user continues from summary' do
        before do
          Timecop.freeze(Date.new(2016, 4, 1)) {
            visit application_confirmation_path(application_id: application.id)
          }
        end

        scenario 'the reference number is not displayed' do
          expect(page).to have_no_content application.reference
        end

        scenario 'the remission register right hand guidance is shown' do
          expect(page).to have_content 'remission register'
        end
      end
    end
  end

  context 'when the reference_date is passed' do
    context 'as a signed in user', js: true do
      before do
        Capybara.current_driver = :webkit
        dwp_api_response 'Yes'
        login_as user
      end

      after { Capybara.use_default_driver }

      context 'after user continues from summary' do
        before do
          Timecop.freeze(Date.new(2016, 8, 1)) {
            visit application_confirmation_path(application_id: application.id)
          }
        end

        scenario 'the reference number is not displayed' do
          expect(page).to have_content application.reference
        end

        scenario 'the remission register right hand guidance is not shown' do
          expect(page).to have_no_content 'remission register'
        end
      end
    end
  end
end
