class IncomesPage < BasePage
  set_url_matcher '/applications/1/incomes'

  section :content, '#content' do
    element :header, 'h1', text: 'Income'
    element :question, 'legend', text: 'In questions 10 and 11, does the applicant financially support any children?'
    element :no, '.govuk-label', text: 'No'
    element :yes, '.govuk-label', text: 'Yes'
    element :number_of_children_hint, '.govuk-hint', text: 'Add number given in questions 10 and 11 together'
    element :number_of_children_error, '.error', text: 'Enter number of children'
    element :total_monthly_income_error, '.error', text: 'Enter the total monthly income'
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

  def submit_incomes_yes_3
    content.yes.click
    fill_in 'Number of children', with: '3'
    fill_in 'Total monthly income', with: '1900'
    next_page
  end
end
