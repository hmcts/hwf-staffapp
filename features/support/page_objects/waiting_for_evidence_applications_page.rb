class WaitingForEvidenceApplicationsPage < BasePage
  set_url('/evidence_checks')

  section :content, '#content' do
    element :header, 'h1', text: 'Waiting for evidence'
    element :no_applications, 'p', text: 'There are no applications waiting for evidence'
  end
end
