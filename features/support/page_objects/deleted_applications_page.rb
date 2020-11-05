class DeletedApplicationsPage < BasePage
  set_url'/deleted_applications'

  section :content, '#content' do
    element :header, 'h1', text: 'Deleted applications'
    element :result, '#result'
  end
end