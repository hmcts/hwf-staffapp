class ApplicationPage < BasePage
  section :content, '#content' do
    sections :summary_section, '.summary-section' do
      element :benefits_header, 'h4', text: 'Benefits'
      element :result_header, 'h4', text: 'Result'
      element :change_benefits, 'a', text: 'Change benefits'
      element :savings_investments_question, '.column-one-third', text: 'Savings and investments'
      element :savings_question, '.column-one-third', text: 'Savings'
      element :benefits_question, '.column-one-third', text: 'Benefits'
      element :benefits_declared_question, '.column-one-third', text: 'Benefits declared in application'
      element :evidence_question, '.column-one-third', text: 'Correct evidence provided'
      element :savings_passed, '.column-two-thirds', text: 'Passed'
      element :benefits_passed, '.column-two-thirds', text: '✓ Passed (paper evidence checked)'
      element :answer_yes, '.column-two-thirds', text: 'Yes'
      element :answer_no, '.column-two-thirds', text: 'No'
    end
  end
end
