class WaitingForEvidenceApplicationsPage < BasePage

  set_url('/evidence_checks')

  section :content, '#content' do
    element :header, 'h1'
  end
end
