class ProcessedApplicationInstancePage < BasePage
  set_url_matcher %r{/processed_applications/[0-9]+}

  section :content, '#content' do
    element :header, 'h1', text: /Processed application$/
    element :result, '#result'
    element :delete_application_detail, 'span', text: 'Delete application'
    element :delete_application_button, '.govuk-button'
    element :enter_the_reason_error, 'label', text: 'Enter the description'
    element :delete_application_textbox, '#application_deleted_reason'
    element :delete_application_select, '#application_deleted_reasons_list'
  end
end
