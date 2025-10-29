RSpec.shared_examples "duplicated NINO for failed DWP" do
  let(:applicant_with_nino) { application_waiting_for_evc.applicant }
  let(:application_waiting_for_evc) { create(:application, :waiting_for_evidence_state, :applicant_full, ni_number: Settings.dwp_mock.ni_number_no.first) }

  before { application_waiting_for_evc }

  scenario do
    start_new_application

    fill_personal_details(Settings.dwp_mock.ni_number_no.first)
    fill_application_refund_details
    fill_saving_and_investment
    fill_benefits(true)
    fill_benefit_evidence(paper_provided: false)

    click_button 'Complete processing'
    expect(page).to have_no_content('Evidence of income needs to be checked')
    expect(page).to have_content('✗   Not eligible for help with fees')
  end
end

RSpec.shared_examples "duplicated NINO for successfull DWP" do
  let(:applicant_with_nino) { application_waiting_for_evc.applicant }
  let(:application_waiting_for_evc) { create(:application, :waiting_for_evidence_state, :applicant_full, ni_number: Settings.dwp_mock.ni_number_yes.first) }

  before { application_waiting_for_evc }

  scenario do
    start_new_application

    fill_personal_details(Settings.dwp_mock.ni_number_yes.first)
    fill_application_refund_details
    fill_saving_and_investment
    fill_benefits(true)
    fill_declaration

    click_button 'Complete processing'
    expect(page).to have_no_content('Evidence of income needs to be checked')
    expect(page).to have_content('✓ Eligible for help with fees')
  end
end
