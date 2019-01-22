class PaperEvidencePage < BasePage
  section :content, '#content' do
    element :no, '.block-label', text: 'No'
    element :yes, '.block-label', text: 'Yes, the applicant has provided paper evidence'
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
