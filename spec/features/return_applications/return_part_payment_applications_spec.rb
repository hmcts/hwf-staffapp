require 'rails_helper'

RSpec.feature 'When part-payment applications are returned', type: :feature do
  include Warden::Test::Helpers
  Warden.test_mode!

  let(:office) { create :office }
  let(:user) { create :user, office: office }

  let(:application1) { create :application_full_remission, :waiting_for_part_payment_state, office: office }
  let(:application2) { create :application_full_remission, :waiting_for_part_payment_state, office: office }
  before do
    create :part_payment, application: application1
    create :part_payment, application: application2
    login_as user
  end

  context 'when on home page' do

    before { visit root_path }

    scenario 'shows the applications that are waiting for part-payment' do
      within '.waiting-for-part_payment' do
        expect(page).to have_content(application1.reference)
        expect(page).to have_content(application2.reference)
      end
    end

    context 'processing an application for return' do
      before { click_link application1.reference }
      scenario 'shows the application data' do
        expect(page).to have_content 'Process part-payment'
        expect(page).to have_content application1.applicant.full_name
        expect(page).to have_link 'Start now'
        expect(page).to have_link 'Return application'
        click_link 'Return application'
        expect(page).to have_content 'Processing complete'
        expect(page).to have_button 'Finish'
        click_button 'Finish'
        expect(page).to have_content 'Start now'
        within '.waiting-for-part_payment' do
          expect(page).to have_no_content(application1.reference)
        end
      end
    end
  end
end
