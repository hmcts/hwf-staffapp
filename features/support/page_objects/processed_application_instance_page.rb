class ProcessedApplicationInstancePage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: /Processed application$/
    element :result, '#result'
  end
end
