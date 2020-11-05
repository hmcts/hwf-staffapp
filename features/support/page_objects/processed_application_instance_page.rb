class ProcessedApplicationInstancePage < BasePage
  set_url_matcher %r{/processed_applications/[0-9]+}

  section :content, '#content' do
    element :header, 'h1', text: /Processed application$/
    element :result, '#result'
  end
end
