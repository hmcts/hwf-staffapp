class ProblemWithEvidencePage < BasePage
  section :content, '#content' do
    element :not_arrived_too_late, '.govuk-label', text: 'Not arrived or too late', visible: false
    element :not_proceeding, '.govuk-label', text: 'Citizen not proceeding', visible: false
    element :staff_error, '.govuk-label', text: 'Staff error'
    element :error, '.error', text: 'Select from one of the options'
  end

  def go_to_problem_with_evidence_page
    dashboard_page.go_home
    click_link("#{reference_prefix}-000001")
    evidence_page.content.evidence_can_not_be_processed.click
    click_link 'Return application', visible: false
  end

  def submit_not_arrived_too_late
    problem_with_evidence_page.content.not_arrived_too_late.click
    next_page
  end

  def submit_not_proceeding
    problem_with_evidence_page.content.not_proceeding.click
    next_page
  end

  def submit_staff_error
    problem_with_evidence_page.content.staff_error.click
    fill_in 'Please add details of the staff error', with: 'These are the details of the staff error'
    next_page
  end
end
