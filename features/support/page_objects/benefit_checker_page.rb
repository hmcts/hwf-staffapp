class BenefitCheckerPage < BasePage
  element :dwp_banner_offline, '.dwp-banner-offline', text: 'DWP checkerYou can’t check an applicant’s benefits. We’re investigating this issue.'
  section :content, '#content' do
    elements :dwp_down_warning, '.dwp-down'
  end
end
