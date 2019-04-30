class ProcessedApplicationsPage < BasePage
  section :content, '#content' do
    element :header, 'h2', text: 'Processed applications'
    element :processed_application_header, 'h2', text: 'PA19-000001 - Processed application'
    element :processed_application_link, 'a', text: 'PA19-000001'
  end
end
