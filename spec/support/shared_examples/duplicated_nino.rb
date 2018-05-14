RSpec.shared_examples "duplicated NINO for failed DWP" do
  let(:applicant_with_nino) { create :applicant, ni_number: 'SN123456C' }
  let(:application_waiting_for_evc) { create :application, :waiting_for_evidence_state, applicant: applicant_with_nino }

  before { application_waiting_for_evc }

  scenario do
    start_new_application

    fill_personal_details('SN123456C')
    fill_application_refund_details
    fill_saving_and_investment
    fill_benefits(true)
    fill_benefit_evidence(paper_provided: false)

    click_button 'Complete processing'
    expect(page).not_to have_content('Evidence of income needs to be checked')
    expect(page).to have_content('✗   Not eligible for help with fees')
  end
end

RSpec.shared_examples "duplicated NINO for successfull DWP" do
  let(:applicant_with_nino) { create :applicant, ni_number: 'SN123456C' }
  let(:application_waiting_for_evc) { create :application, :waiting_for_evidence_state, applicant: applicant_with_nino }

  before { application_waiting_for_evc }

  scenario do
    start_new_application

    fill_personal_details('SN123456C')
    fill_application_refund_details
    fill_saving_and_investment
    fill_benefits(true)

    click_button 'Complete processing'
    expect(page).not_to have_content('Evidence of income needs to be checked')
    expect(page).to have_content('✓ Eligible for help with fees')
  end
end