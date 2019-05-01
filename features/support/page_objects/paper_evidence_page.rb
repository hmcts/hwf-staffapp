class PaperEvidencePage < BasePage
  section :content, '#content' do
    element :no, 'label', text: 'No'
    element :yes, 'label', text: 'Yes, the applicant has provided paper evidence'
  end

  def go_to_paper_evidence_page
    personal_details_page.submit_all_personal_details
    application_details_page.submit_fee_600
    savings_investments_page.submit_less_than
    benefits_page.submit_benefits_yes
  end

  def submit_evidence_yes
    content.yes.click
    next_page
  end

  def submit_evidence_no
    content.no.click
    next_page
  end
end
