class BenefitCheckerPage < BasePage
  set_url_matcher %r{/applications/[0-9]+/benefit_override/paper_evidence}

  element :dwp_banner_offline, '.dwp-banner-offline', text: 'DWP checkerYou can’t check an applicant’s benefits. We’re investigating this issue.'
  element :dwp_banner_online, '.dwp-banner-online', text: 'DWP checkerYou can process benefits and income based applications.'
  section :content, '#content' do
    element :header, 'h1', text: 'Evidence of benefits'
    element :dwp_down_warning, '.dwp-down'
    element :paper_evidence_warning, '.page-error', text: 'You will only be able to process this application if you have supporting evidence that the applicant is receiving benefits'
    element :no, 'label', text: 'No'
    element :yes, 'label', text: 'Yes, the applicant has provided supporting evidence'
    element :next, 'input[value="Next"]'
  end

  def click_next
    content.wait_until_next_visible
    content.next.click
  end
end
