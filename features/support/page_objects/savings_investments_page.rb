class SavingsInvestmentsPage < BasePage
  set_url_matcher %r{applications/[0-9]+/savings_investments}

  element :help_with_fees_home, 'a', text: 'Help with fees'
  section :content, '#content' do
    element :header, 'h1', text: 'Savings and investments'
    element :less_than, 'label', text: 'Less than £3,000', visible: false
    element :less_than_ucd, 'label', text: 'Less than £4,250', visible: false
    element :between_ucd, 'label', text: 'Between £4,250 and £15,999', visible: false
    element :more_than, 'label', text: '£3,000 or more', visible: false
    element :more_than_ucd, 'label', text: '£16,000 or more', visible: false
    element :under_66, 'label', text: 'No', visible: false
    element :over_66, 'label', text: 'Yes', visible: false
    element :savings_amount_label, 'label', text: 'How much do they have in savings and investments?'
    element :application_amount, '#application_amount'
    element :blank_error, 'label', text: 'Please enter the amount of savings and investments'
    element :inequality_error, 'label', text: 'Value must be greater than or equal to 3000'
    element :non_numerical_error, 'label', text: 'The value that you entered is not a number'
    element :no_answer_error, 'label', text: 'Please answer the savings question'
    element :not_66_error, 'label', text: 'Age selection does not match applicant Date of Birth entered'
    element :next, 'input[value="Next"]'
  end

  def submit_less_than
    content.wait_until_less_than_visible
    content.less_than.click
    click_next
  end

  def submit_less_than_ucd
    content.wait_until_less_than_ucd_visible
    content.less_than_ucd.click
    click_next
  end

  def submit_more_than
    content.wait_until_more_than_visible
    content.more_than.click
  end

  def submit_more_than_ucd
    content.wait_until_more_than_ucd_visible
    content.more_than_ucd.click
    click_next
  end

  def submit_between_under_66_ucd
    content.wait_until_between_ucd_visible
    content.between_ucd.click
    content.under_66.click
  end

  def submit_between_over_66_ucd
    content.wait_until_between_ucd_visible
    content.between_ucd.click
    content.over_66.click
    click_next
  end

  def submit_amount_1000
    content.wait_until_application_amount_visible
    content.application_amount.set '1000'
    click_next
  end

  def submit_amount_5000
    content.wait_until_application_amount_visible
    content.application_amount.set '5000'
    click_next
  end

  def submit_amount_15000
    content.wait_until_application_amount_visible
    content.application_amount.set '15000'
    click_next
  end

  def submit_abc
    content.wait_until_application_amount_visible
    content.application_amount.set 'abc'
    click_next
  end

  def submit_exact_amount
    content.wait_until_more_than_visible
    content.more_than.click
    content.wait_until_application_amount_visible
    content.application_amount.set '10000.01'
    click_next
  end

  def submit_exact_amount_ucd
    content.wait_until_between_ucd_visible
    content.between_ucd.click
    content.under_66.click
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
