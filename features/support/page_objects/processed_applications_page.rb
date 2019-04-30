class ProcessedApplicationsPage < BasePage
  section :content, '#content' do
    element :header, 'h2', text: 'Processed applications'
  end
end