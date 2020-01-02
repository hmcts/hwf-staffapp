class ProcessedApplicationsPage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'Processed applications'
    element :processed_application_header, 'h1'
  end
end
