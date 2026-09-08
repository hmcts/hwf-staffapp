class IncomeKindPartnerPage < BasePage
  set_url_matcher %r{/applications/[0-9]+/income_kind_partners}

  section :content, '#content' do
    element :header, 'h1', text: 'Type of income the partner is receiving'
    element :wages, 'label', text: 'Wages before tax and National Insurance are taken off'
    element :next, 'input[value="Next"]'
  end

  def click_next
    content.wait_until_next_visible
    content.next.click
  end

  def submit_wages
    content.wait_until_wages_visible
    content.wages.click
    click_next
  end
end
