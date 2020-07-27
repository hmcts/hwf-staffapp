class BenefitsPage < BasePage
  set_url '/applications/1/incomes'

  section :content, '#content' do
    element :header, 'h1', text: 'Benefits the applicant is receiving'
    element :benefit_question, '.govuk-label', text: 'Is the applicant receiving one of these benefits?'
    element :no, 'label', text: 'No', visible: false
    element :yes, 'label', text: 'Yes', visible: false
  end

  def go_to_benefits_page
    personal_details_page.submit_required_personal_details
    application_details_page.submit_fee_600
    savings_investments_page.submit_less_than
  end

  def submit_benefits_yes
    content.yes.click
    click_button 'Next'
  end

  def submit_benefits_no
    content.wait_until_no_visible
    content.no.click
    next_page
  end
end
