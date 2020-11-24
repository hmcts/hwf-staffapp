class SavingsInvestmentsPage < BasePage
  set_url_matcher %r{applications/[0-9]+/savings_investments}

  element :help_with_fees_home, 'a', text: 'Help with fees'
  section :content, '#content' do
    element :header, 'h1', text: 'Savings and investments'
    element :less_than, 'label', text: 'Less than £3,000', visible: false
    element :more_than, 'label', text: '£3,000 or more', visible: false
    element :savings_amount_label, 'label', text: 'How much do they have in savings and investments?'
    element :application_amount, '#application_amount'
    element :blank_error, 'label', text: 'Please enter the amount of savings and investments'
    element :inequality_error, 'label', text: 'Value must be greater than or equal to 3000'
    element :non_numerical_error, 'label', text: 'The value that you entered is not a number'
    element :no_answer_error, 'label', text: 'Please answer the savings question'
    element :next, 'input[value="Next"]'
  end

  def submit_less_than
    content.wait_until_less_than_visible
    content.less_than.click
    click_next
  end

  def submit_more_than
    content.wait_until_more_than_visible
    content.more_than.click
  end

  def submit_exact_amount
    content.wait_until_more_than_visible
    content.more_than.click
    content.wait_until_application_amount_visible
    content.application_amount.set '10000.01'
    click_next
  end

  def go_home
    wait_until_help_with_fees_home_visible
    help_with_fees_home.click
  end

  def click_next
    content.wait_until_next_visible
    content.next.click
  end
end
