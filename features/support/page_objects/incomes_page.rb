class IncomesPage < BasePage
  section :content, '#content' do
    element :no, '.block-label', text: 'No'
    element :yes, '.block-label', text: 'Yes'
  end

  def submit_incomes_no
    content.no.click
    content.fill_in 'Total monthly income', with: '1200'
    next_page
  end

  def submit_incomes_yes
    content.yes.click
  end
end
