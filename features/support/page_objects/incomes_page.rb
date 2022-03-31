class IncomesPage < BasePage
  set_url_matcher %r{/applications/[0-9]+/incomes}

  section :content, '#content' do
    element :header, 'h1', text: 'Income'
    element :question, 'legend', text: 'In questions 10 and 11, does the applicant financially support any children?'
    elements :radio, '.govuk-radios label'
    element :number_of_children_hint, '.govuk-hint', text: 'Add number given in questions 10 and 11 together'
    element :number_of_children_error, '.error', text: 'Enter number of children'
    element :total_monthly_income_error, '.error', text: 'Enter the total monthly income'
    element :next, 'input[value="Next"]'
  end

  def submit_incomes_0
    incomes_page.content.wait_until_question_visible
    find_field('Total monthly income', visible: false).set('0.5')
    click_next
  end

  def submit_incomes_50
    incomes_page.content.wait_until_question_visible
    find_field('Total monthly income', visible: false).set('50')
    click_next
  end

  def submit_incomes_1200
    incomes_page.content.wait_until_question_visible
    find_field('Total monthly income', visible: false).set('1200')
    click_next
  end

  def submit_incomes(num)
    incomes_page.content.wait_until_question_visible
    find_field('Total monthly income', visible: false).set(num)
    click_next
  end

  def submit_incomes_no
    incomes_page.content.wait_until_question_visible
    incomes_page.content.radio[0].click
  end

  def submit_incomes_yes_3
    incomes_page.content.wait_until_question_visible
    incomes_page.content.radio[1].click
    find_field('Number of children', visible: false).set('3')
    find_field('Total monthly income', visible: false).set('1900')
    click_next
  end

  def click_next
    content.wait_until_next_visible
    content.next.click
  end
end
