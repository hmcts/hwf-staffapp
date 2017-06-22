require 'rails_helper'

RSpec.feature 'Online application processing Evidence check', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:jurisdiction) { create :jurisdiction }
  let(:office) { create :office, jurisdictions: [jurisdiction] }
  let(:user) { create :user, office: office }
  let(:online_application_1) { create :online_application, :completed, :with_reference,
    married: false,
    children: 3,
    benefits: false,
    fee: 155,
    form_name: 'D11',
    income_min_threshold_exceeded: false
  }
  let(:online_application_2) { create :online_application, :completed, :with_reference,
    married: false,
    children: 0,
    benefits: true,
    fee: 155,
    form_name: 'D11',
    emergency_reason: 'freezing order',
    ni_number: online_application_1.ni_number
  }
  let(:old_application) { create :old_application, reference: online_application_1.reference}


  before do
    login_as user
    dwp_api_response 'Yes'
    create_list :application_part_remission, 9
  end

  scenario 'Processing benefit based application with previois' do
    visit  home_index_url

    fill_in 'Reference', with: online_application_1.reference
    click_button 'Look up'

    choose Jurisdiction.first.display_full.to_s
    click_button 'Next'
    click_button 'Complete processing'
    expect(page).to have_text 'Evidence of income needs to be checked'
    click_link 'Back to start'

    reference = Application.last.reference
    click_link reference

    # because it's 10th so random evidence check
    expect(page).to have_text("#{reference} - Waiting for evidence")
    click_link 'Return application'
    click_button 'Finish'

    expect(page).to have_text('There are no applications waiting for part-payment')
    online_application_2

    fill_in 'Reference', with: online_application_2.reference
    click_button 'Look up'

    choose Jurisdiction.first.display_full.to_s
    click_button 'Next'
    click_button 'Complete processing'
    # because there is a flag from previous check
    expect(page).to have_text 'Evidence of income needs to be checked'
    click_link 'Back to start'
    click_link Application.last.reference
    click_link 'Start now'
    choose 'Yes, the evidence is for the correct applicant and dated in the last 3 months'
    click_button 'Next'

    fill_in 'evidence_income', with: '1359'
    click_button 'Next'
    expect(page).to have_text('The applicant must pay £135 towards the fee')
  end
end