# rubocop:disable Metrics/AbcSize
def go_to_application_details_page
  personal_details_page.submit_all_personal_details_ni
end

def go_to_finance_transactional_report_page
  visit(reports_page.url)
  expect(reports_page).to have_current_path(%r{/reports})
  reports_page.finance_transactional_report
end

def go_to_paper_evidence_page
  personal_details_page.submit_all_personal_details_ni
  expect(application_details_page).to have_current_path(%r{/details})
  application_details_page.submit_fee_600
  expect(savings_investments_page).to have_current_path(%r{/savings_investments})
  savings_investments_page.submit_less_than
  expect(benefits_page).to have_current_path(%r{/benefits})
  benefits_page.submit_benefits_yes
  expect(savings_investments_page).to have_current_path(%r{/paper_evidence})
end

def go_to_problem_with_evidence_page
  click_reference_link
  expect(evidence_page).to have_current_path(%r{/evidence/[0-9]+})
  evidence_page.content.wait_until_evidence_can_not_be_processed_visible
  evidence_page.content.evidence_can_not_be_processed.click
  evidence_page.content.wait_until_return_application_visible
  evidence_page.content.return_application.click
  expect(page).to have_current_path(%r{/evidence/accuracy_failed_reason/[1-9]+})
end

def go_to_savings_investment_page
  personal_details_page.submit_required_personal_details
  expect(application_details_page).to have_current_path(%r{/details})
  application_details_page.submit_fee_600
  expect(savings_investments_page).to have_current_path(%r{/savings_investments})
end

# rubocop:disable Metrics/MethodLength
def go_to_summary_page_low_savings
  start_application
  expect(dashboard_page).to have_current_path('/')
  dashboard_page.process_application
  expect(personal_details_page).to have_current_path(%r{/personal_informations})
  personal_details_page.submit_all_personal_details_ni
  expect(application_details_page).to have_current_path(%r{/details})
  application_details_page.submit_fee_600
  expect(savings_investments_page).to have_current_path(%r{/savings_investments})
  savings_investments_page.submit_less_than
  expect(benefits_page).to have_current_path(%r{/benefits})
  benefits_page.submit_benefits_yes
  expect(paper_evidence_page).to have_current_path(%r{/paper_evidence})
  paper_evidence_page.submit_evidence_yes
  expect(summary_page).to have_current_path(%r{/summary})
end
# rubocop:enable Metrics/MethodLength

def go_to_summary_page_high_savings
  start_application
  expect(dashboard_page).to have_current_path('/')
  dashboard_page.process_application
  expect(personal_details_page).to have_current_path(%r{/personal_informations})
  personal_details_page.submit_all_personal_details_ni
  expect(application_details_page).to have_current_path(%r{/details})
  application_details_page.submit_fee_600
  expect(savings_investments_page).to have_current_path(%r{/savings_investments})
  savings_investments_page.submit_exact_amount
  expect(summary_page).to have_current_path(%r{/summary})
end

def go_to_pending_applications
  dashboard_page.content.wait_until_pending_applications_link_visible
  dashboard_page.content.pending_applications_link.click
end
# rubocop:enable Metrics/AbcSize
