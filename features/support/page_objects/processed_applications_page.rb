class ProcessedApplicationsPage < BasePage
  section :content, '#content' do
    element :header, 'h1'
    element :result, '#result'
  end
end
