require 'rails_helper'

RSpec.feature 'Evidence check' do

  include Warden::Test::Helpers

  Warden.test_mode!

  let(:jurisdiction) { create(:jurisdiction) }
  let(:office) { create(:office, jurisdictions: [jurisdiction]) }
  let(:user) { create(:user, office: office) }
  let(:detail) { create(:complete_detail, calculation_scheme: calculation_scheme) }
  let(:calculation_scheme) { FeatureSwitching::CALCULATION_SCHEMAS[1].to_s }
  let(:application) { create(:application_full_remission_ev, user: user, office: office, detail: detail) }

  before do
    login_as user
    application
  end

  scenario 'Processing evidence check full' do
    visit evidence_path(application.evidence_check)

    expect(page).to have_text("#{application.reference} - Waiting for evidence")
    click_link 'Start now'

    expect(page).to have_text 'Is the evidence ready to process?'
    choose "Yes, the evidence is for the correct applicant and covers the correct time period"
    click_button 'Next'

    expect(page).to have_text 'Total monthly income from evidence'
    fill_in 'evidence_income', with: 10
    click_button 'Next'

    expect(page).to have_text '✓ Eligible for help with fees'
    click_link 'Next'

    expect(page).to have_text 'Check details'
    expect(page).to have_text 'Total income10'

    expect(page).to have_text '✓ Eligible for help with fees'
    click_button 'Complete processing'

    expect(page).to have_text 'Application complete'
    expect(page).to have_text '✓ Eligible for help with fees'
  end

  scenario 'Return evidence check' do
    visit evidence_path(application.evidence_check)
    expect(page).to have_text("#{application.reference} - Waiting for evidence")
    expect(page).to have_text "What to do if evidence hasn't arrived"
    expect(page).to have_text "choose 'Return application' to remove it from 'Waiting for evidence' and return everything to the applicant."

    click_link 'Return application'
    expect(page).to have_text 'What is the problem?'

    choose "Citizen not proceeding"
    click_button 'Next'

    expect(page).to have_text 'Processing complete'
    expect(application.reload.state).to eq 'processed'

    click_link "Back to start"
    expect(page).to have_no_text 'This application has been processed. You can’t edit any details.'
  end

end
