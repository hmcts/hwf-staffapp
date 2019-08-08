class EvidenceAccuracyPage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'Evidence'
    element :eligibility, 'h3', text: 'Eligible for help with fees'
    element :personal_details, 'h2', text: 'Personal details'
    element :application_details, 'h2', text: 'Application details'
    element :benefits, 'h2', text: 'Benefits'
    element :income, 'h2', text: 'Income'
    element :result, 'h2', text: 'Result'
    element :processing_summary, 'h4', text: 'Processing summary'
    element :evidence_can_not_be_processed, '.summary', text: 'What to do if the evidence can’t be processed'
    element :evidence_deadline, 'p'
    element :correct_evidence, '.govuk-label', text: 'Yes, the evidence is for the correct applicant and dated in the last 3 months'
    element :problem_with_evidence, '.govuk-label', text: 'No, there is a problem with the evidence and it needs to be returned'
    element :answer_question_error, '.error', text: 'This question must be answered'
  end
end
