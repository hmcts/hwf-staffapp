class BenefitCheckerPage < BasePage
  set_url_matcher %r{/applications/[0-9]+/benefit_override/paper_evidence}

  element :dwp_banner_offline, '.dwp-banner-offline', text: 'DWP checkerYou can’t check an applicant’s benefits. We’re investigating this issue.'
  element :dwp_banner_online, '.dwp-banner-online', text: 'DWP checkerYou can process benefits and income based applications.'
  section :content, '#content' do
    element :header, 'h1', text: 'Evidence of benefits'
    element :dwp_down_warning, '.dwp-down'
    element :paper_evidence_warning, '.page-error', text: 'This could be due to a system error and/or the applicant not being found from the details provided.'
    element :no, 'label', text: 'No'
    element :yes, 'label', text: 'Yes, by selecting this option, the applicant will be issued with a full remission'
    element :next, 'input[value="Next"]'
  end

  def click_next
    content.wait_until_next_visible
    content.next.click
  end
end
