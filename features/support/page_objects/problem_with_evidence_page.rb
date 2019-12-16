class ProblemWithEvidencePage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'What is the problem?'
    element :not_arrived_too_late, '.govuk-label', text: 'Not arrived or too late'
    element :not_proceeding, '.govuk-label', text: 'Citizen not proceeding'
    element :staff_error, '.govuk-label', text: 'Staff error'
    element :error, '.error', text: 'Select from one of the options'
  end

  def go_to_problem_with_evidence_page
    waiting_evidence_application
    waiting_evidence_application
    click_link('PA19-000002')
    evidence_page.content.evidence_can_not_be_processed.click
    click_link('Return application')
  end
end
