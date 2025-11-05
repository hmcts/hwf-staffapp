class PaperEvidencePage < BasePage
  set_url_matcher %r{/applications/[0-9]+/benefit_override/paper_evidence}

  section :content, '#content' do
    element :header, 'h1', text: 'Evidence of benefits'
    element :no, 'label', text: 'No', visible: false
    element :yes, 'label', text: 'Yes, by selecting this option, the applicant will be issued with a full remission', visible: false
    element :next, 'input[value="Next"]'
  end

  def submit_evidence_yes
    content.wait_until_yes_visible
    content.yes.click
    click_next
  end

  def submit_evidence_no
    content.wait_until_no_visible
    content.no.click
    click_next
  end

  def click_next
    content.wait_until_next_visible
    content.next.click
  end
end
