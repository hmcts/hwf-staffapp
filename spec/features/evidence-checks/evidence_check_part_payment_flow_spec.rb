require 'rails_helper'

RSpec.feature 'Part payment application with evidence check', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:jurisdiction) { create :jurisdiction }
  let(:office) { create :office, jurisdictions: [jurisdiction] }
  let(:user) { create :user, office: office }

  before do
    login_as user
  end

  let(:application) do
    create :application_part_remission, :refund,
      office: office, jurisdiction: jurisdiction,
      fee: 5000,
      income: 3083,
      children: 2
  end

  scenario 'Is marked as waiting for payment after providing evidence' do
    create_list :application_full_remission, 1, :refund

    visit application_summary_path(application)

    click_button 'Complete processing'

    expect(page).to have_content 'Evidence of income needs to be checked'

    application = Application.last

    expect(evidence_check_rendered?).to be true

    click_link 'Back to start'

    within('table.waiting-for-evidence') do
      click_link application.reload.reference
    end

    expect(page).to have_content("#{application.reference} - Waiting for evidence")
    click_link 'Start now'

    expect(page).to have_content 'Is the evidence ready to process?'
    choose "Yes, the evidence is for the correct applicant and dated in the last 3 months"
    click_button 'Next'

    fill_in 'evidence_income', with: 3951
    click_button 'Next'

    expect(page).to have_content 'The applicant must pay £1105 towards the fee'
    click_link 'Next'

    expect(page).to have_content 'Check details'
    click_button 'Complete processing'

    expect(application.reload.state).to eql('waiting_for_part_payment')
  end

  def evidence_check_rendered?
    (%r{\/evidence_checks\/#{application.evidence_check.id}} =~ page.current_url) != nil
  end
end
