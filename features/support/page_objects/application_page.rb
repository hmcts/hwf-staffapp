class ApplicationPage < BasePage
  section :content, '#content' do
    element :benefits_header, 'h2', text: 'Benefits'
    element :result_header, 'h2', text: 'Result'
    sections :summary_section, '.govuk-summary-list' do
      element :change_benefits, 'a', text: 'Change benefits'
      element :savings_investments_question, '.govuk-summary-list__key', text: 'Savings and investments'
      element :savings_question, '.govuk-summary-list__key', text: 'Savings'
      element :benefits_question, '.govuk-summary-list__key', text: 'Benefits'
      element :benefits_declared_question, '.govuk-summary-list__key', text: 'Benefits declared in application'
      element :evidence_question, '.govuk-summary-list__key', text: 'Correct evidence provided'
      element :savings_passed, '.govuk-summary-list__value', text: 'Passed'
      element :benefits_passed_with_paper_evidence, '.govuk-summary-list__value', text: '✓ Passed (paper evidence checked)'
      element :benefits_passed, '.govuk-summary-list__value', text: '✓ Passed'
      element :answer_yes, '.govuk-summary-list__value', text: 'Yes'
      element :answer_no, '.govuk-summary-list__value', text: 'No'
      element :income_question_children, '.govuk-summary-list__key', text: 'Applicant has children'
      element :income_question_number_of_children, '.govuk-summary-list__key', text: 'Number of children'
      element :income_question_total, '.govuk-summary-list__key', text: 'Total income'
    end
  end
end
