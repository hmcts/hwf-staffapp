class IncomesPage < BasePage
  set_url_matcher %r{/applications/[0-9]+/incomes}

  section :content, '#content' do
    element :header, 'h1', text: 'Income'
    element :question, 'legend', text: 'In questions 10 and 11, does the applicant financially support any children?'
    element :question_ucd, 'label', text: 'In question 13, what income has been entered?'
    elements :radio, '.govuk-radios label'
    element :number_of_children_hint, '.govuk-hint', text: 'Add number given in questions 10 and 11 together'
    element :number_of_children_error, '.error', text: 'Enter number of children'
    element :total_monthly_income_error, '.error', text: 'Enter the total monthly income'
    element :income_period_last_month, '#application_income_period_last_month', text: 'Last calendar month'
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

  def submit_incomes_50_ucd
    incomes_page.content.wait_until_question_ucd_visible

    find('#application_income', visible: false).set('50')
    find_field('Last calendar month', visible: false).click
    click_next
  end

  def submit_incomes_1200
    incomes_page.content.wait_until_question_visible
    find_field('Total monthly income', visible: false).set('1200')
    click_next
  end

  def submit_incomes_1200_ucd
    incomes_page.content.wait_until_question_ucd_visible

    find('#application_income', visible: false).set('1200')
    find_field('Last calendar month', visible: false).click
    click_next
  end

  def submit_incomes_2000
    incomes_page.content.wait_until_question_visible
    find_field('Total monthly income', visible: false).set('2000')
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
