class ProblemWithEvidencePage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'What is the problem with the evidence?'
    element :not_arrived_too_late, '.govuk-label', text: 'Not arrived or too late'
    element :error, '.error', text: 'Please select from one of the options'
  end

  def go_to_problem_with_evidence_page
    waiting_evidence_application
    waiting_evidence_application
    click_link('PA19-000002')
    click_link('Start now')
    evidence_accuracy_page.content.problem_with_evidence.click
    next_page
  end
end
