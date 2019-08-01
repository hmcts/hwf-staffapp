class EvidenceAccuracyPage < BasePage
  section :content, '#content' do
    element :header, 'h2', text: 'Evidence'
    element :eligibility, 'h3', text: 'Eligible for help with fees'
    element :personal_details, 'h4', text: 'Personal details'
    element :application_details, 'h4', text: 'Application details'
    element :benefits, 'h4', text: 'Benefits'
    element :income, 'h4', text: 'Income'
    element :result, 'h4', text: 'Result'
    element :processing_summary, 'h4', text: 'Processing summary'
    element :evidence_can_not_be_processed, '.summary', text: 'What to do if the evidence can’t be processed'
    element :evidence_deadline, 'p'
    element :correct_evidence, '.block-label', text: 'Yes, the evidence is for the correct applicant and dated in the last 3 months'
    element :problem_with_evidence, '.block-label', text: 'No, there is a problem with the evidence and it needs to be returned'
    element :answer_question_error, '.error', text: 'This question must be answered'
  end
end
