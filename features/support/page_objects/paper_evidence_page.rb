class PaperEvidencePage < BasePage
  section :content, '#content' do
    element :no, 'label', text: 'No', visible: false
    element :yes, 'label', text: 'Yes, the applicant has provided paper evidence', visible: false
  end

  def go_to_paper_evidence_page
    personal_details_page.submit_all_personal_details_ni
    application_details_page.submit_fee_600
    savings_investments_page.submit_less_than
    benefits_page.submit_benefits_yes
  end

  def submit_evidence_yes
    content.yes.click
    click_on 'Next', visible: false
  end

  def submit_evidence_no
    content.no.click
    click_on 'Next', visible: false
  end
end
