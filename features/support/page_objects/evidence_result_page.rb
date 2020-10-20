class EvidenceResultPage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'Income result'
    element :eligable_header, 'h2', text: '✓ Eligible for help with fees'
    element :not_eligable_header, 'h2', text: '✗ Not eligible for help with fees'
    element :next, 'a', text: 'Next'
  end

  def click_next
    content.wait_until_next_visible
    content.next.click
  end
end
