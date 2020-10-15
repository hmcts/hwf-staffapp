class EvidenceAccuracyPage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'Is the evidence ready to process?'
    element :correct_evidence, 'label', text: 'Yes, the evidence is for the correct applicant and covers the correct time period'
    element :problem_with_evidence, 'label', text: 'No, there is a problem with the evidence and it needs to be returned'
    element :next, 'input[value="Next"]'
  end

  def click_next
    content.wait_until_next_visible
    content.next.click
  end
end
