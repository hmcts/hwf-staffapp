class IncomesPage < BasePage
  set_url '/applications/1/incomes'

  section :content, '#content' do
    element :header, 'h1', text: 'Income'
    element :question, 'legend', text: 'In questions 10 and 11, does the applicant financially support any children?'
    element :no, '.govuk-label', text: 'No'
    element :yes, '.govuk-label', text: 'Yes'
  end

  def go_to_incomes_page
    personal_details_page.submit_required_personal_details
    application_details_page.submit_fee_600
    savings_investments_page.submit_less_than
    benefits_page.submit_benefits_no
  end

  def submit_incomes_50
    fill_in 'Total monthly income', with: '50'
    next_page
  end

  def submit_incomes_1200
    fill_in 'Total monthly income', with: '1200'
    next_page
  end

  def submit_incomes_no
    content.no.click
  end

  def submit_incomes_yes
    content.yes.click
  end
end
