class SavingsInvestmentsPage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'Savings and investments'
    element :less_than, 'label', text: 'Less than £3,000', visible: false
    element :more_than, 'label', text: 'More than £3,000', visible: false
    element :savings_amount_label, 'label', text: 'How much do they have in savings and investments?'
    element :application_amount, '#application_amount'
  end

  def go_to_savings_investment_page
    personal_details_page.submit_required_personal_details
    application_details_page.submit_fee_600
  end

  def submit_less_than
    content.less_than.click
    click_on 'Next', visible: false
  end

  def submit_more_than
    content.more_than.click
  end

  def submit_exact_amount
    content.more_than.click
    content.application_amount.set '10000.01'
    click_on 'Next', visible: false
  end
end
