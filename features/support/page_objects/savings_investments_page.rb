class SavingsInvestmentsPage < BasePage
  section :content, '#content' do
    element :header, 'h2', text: 'Savings and investments'
    element :less_than, '.block-label', text: 'Less than £3,000'
    element :more_than, '.block-label', text: 'More than £3,000'
    element :savings_amount_label, '.form-label', text: 'How much do they have in savings and investments?'
    element :application_amount, '#application_amount', text: ''
  end

  def submit_less_than
    content.less_than.click
    next_page
  end

  def submit_more_than
    content.more_than.click
  end

  def submit_exact_amount
    content.more_than.click
    content.application_amount.set '10000'
    next_page
  end
end
