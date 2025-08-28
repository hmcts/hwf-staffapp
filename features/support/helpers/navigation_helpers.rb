# rubocop:disable Metrics/AbcSize
def go_to_application_details_page
  fee_status_page.submit_date_received_no_refund
  personal_details_page.submit_all_personal_details_ni
end

def go_to_finance_transactional_report_page
  visit(reports_page.url)
  expect(reports_page.content).to have_management_information_header
  reports_page.finance_transactional_report
end

def go_to_paper_evidence_page
  personal_details_page.submit_all_personal_details_ni
  expect(application_details_page.content).to have_header
  application_details_page.submit_fee_600
  expect(savings_investments_page.content).to have_header
  savings_investments_page.submit_less_than_ucd
  stub_dwp_response_as_bad_request
  expect(benefits_page.content).to have_header
  benefits_page.submit_benefits_yes
  expect(paper_evidence_page.content).to have_header
end

def go_to_problem_with_evidence_page
  click_reference_link
  expect(evidence_page.content).to have_waiting_for_evidence_instance_header
  evidence_page.content.wait_until_evidence_can_not_be_processed_visible
  evidence_page.content.evidence_can_not_be_processed.click
  evidence_page.content.wait_until_return_application_visible
  evidence_page.content.return_application.click
  expect(problem_with_evidence_page.content).to have_header
end

def go_to_savings_investment_page
  expect(fee_status_page.content).to have_header
  fee_status_page.submit_date_received_no_refund
  expect(personal_details_page.content).to have_header
  personal_details_page.submit_required_personal_details
  expect(application_details_page.content).to have_header
  application_details_page.submit_fee_2000
  expect(savings_investments_page.content).to have_header
end

def go_to_savings_investment_page_over_66
  expect(fee_status_page.content).to have_header
  fee_status_page.submit_date_received_no_refund
  expect(personal_details_page.content).to have_header
  personal_details_page.submit_required_personal_details_66
  expect(application_details_page.content).to have_header
  application_details_page.submit_fee_2000
  expect(savings_investments_page.content).to have_header
end

# rubocop:disable Metrics/MethodLength
def go_to_summary_page_low_savings_paper_evidence_benefit_check
  start_application
  expect(dashboard_page.content).to have_find_an_application_heading
  dashboard_page.process_application
  expect(fee_status_page.content).to have_header
  fee_status_page.submit_date_received_no_refund
  expect(personal_details_page.content).to have_header
  personal_details_page.submit_all_personal_details_ni_with_no_answer_for_benefits
  expect(application_details_page.content).to have_header
  application_details_page.submit_fee_600
  expect(savings_investments_page.content).to have_header
  savings_investments_page.submit_less_than_ucd
  expect(benefits_page.content).to have_header
  benefits_page.submit_benefits_yes
  expect(paper_evidence_page.content).to have_header
  paper_evidence_page.submit_evidence_yes
  declaration_page.sign_by_applicant
  expect(summary_page.content).to have_header
end
# rubocop:enable Metrics/MethodLength

# rubocop:disable Metrics/MethodLength
def go_to_summary_page_low_savings
  start_application
  expect(dashboard_page.content).to have_find_an_application_heading
  dashboard_page.process_application
  expect(fee_status_page.content).to have_header
  fee_status_page.submit_date_received_no_refund
  expect(personal_details_page.content).to have_header
  personal_details_page.submit_all_personal_details_ni
  expect(application_details_page.content).to have_header
  application_details_page.submit_fee_600
  expect(savings_investments_page.content).to have_header
  savings_investments_page.submit_less_than_ucd
  expect(benefits_page.content).to have_header
  benefits_page.submit_benefits_yes
  declaration_page.sign_by_applicant
  expect(summary_page.content).to have_header
end
# rubocop:enable Metrics/MethodLength

def go_to_summary_page_high_savings
  start_application
  expect(dashboard_page.content).to have_find_an_application_heading
  dashboard_page.process_application
  expect(fee_status_page.content).to have_header
  fee_status_page.submit_date_received_no_refund
  expect(personal_details_page.content).to have_header
  personal_details_page.submit_all_personal_details_ni
  expect(application_details_page.content).to have_header
  application_details_page.submit_fee_600
  expect(savings_investments_page.content).to have_header
  savings_investments_page.submit_exact_amount_ucd
  declaration_page.sign_by_applicant
  expect(summary_page.content).to have_header
end

def go_to_pending_applications
  dashboard_page.content.wait_until_pending_applications_link_visible
  dashboard_page.content.pending_applications_link.click
end
# rubocop:enable Metrics/AbcSize
