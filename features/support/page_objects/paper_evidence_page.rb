class PaperEvidencePage < BasePage
  section :content, '#content' do
    element :no, 'label', text: 'No', visible: false
    element :yes, 'label', text: 'Yes, the applicant has provided paper evidence', visible: false
    element :next, 'input[value="Next"]'
  end

  def go_to_paper_evidence_page
    personal_details_page.submit_all_personal_details_ni
    application_details_page.submit_fee_600
    savings_investments_page.submit_less_than
    benefits_page.submit_benefits_yes
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
