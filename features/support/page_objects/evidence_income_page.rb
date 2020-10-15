class EvidenceIncomePage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'Income'
    element :next, 'input[value="Next"]'
  end

  def click_next
    content.wait_until_next_visible
    content.next.click
  end
end
