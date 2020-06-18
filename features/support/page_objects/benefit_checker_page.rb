class BenefitCheckerPage < BasePage
  element :dwp_banner_offline, '.dwp-banner-offline', text: 'DWP checkerYou can’t check an applicant’s benefits. We’re investigating this issue.'
  section :content, '#content' do
    element :dwp_down_warning, '.dwp-down'
    element :paper_evidence_warning, '.page-error', text: 'You will only be able to process this application if you have paper evidence that the applicant is receiving benefits'
    element :no, 'label', text: 'No'
    element :yes, 'label', text: 'Yes, the applicant has provided paper evidence'
  end
end
