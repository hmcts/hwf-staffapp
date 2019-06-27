class IncomesPage < BasePage
  section :content, '#content' do
    element :no, '.govuk-label', text: 'No'
    element :yes, '.govuk-label', text: 'Yes'
  end

  def submit_incomes_no_50
    content.no.click
    fill_in 'Total monthly income', with: '50'
    next_page
  end

  def submit_incomes_no_1200
    content.no.click
    fill_in 'Total monthly income', with: '1200'
    next_page
  end

  def submit_incomes_yes
    content.yes.click
  end
end
