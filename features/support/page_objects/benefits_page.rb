class BenefitsPage < BasePage
  set_url '/applications/1/incomes'

  section :content, '#content' do
    element :header, 'h1', text: 'Benefits the applicant is receiving'
    element :benefit_question, '.govuk-label', text: 'Is the applicant receiving one of these benefits?'
  end

  def go_to_benefits_page
    personal_details_page.submit_required_personal_details
    application_details_page.submit_fee_600
    savings_investments_page.submit_less_than
  end

  def submit_benefits_yes
    choose 'Yes', visible: false
    next_page
  end

  def submit_benefits_no
    choose 'No', visible: false
    next_page
  end
end
