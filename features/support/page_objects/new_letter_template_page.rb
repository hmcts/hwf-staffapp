class NewLetterTemplatePage < BasePage
  set_url '/new_letter_templates'

  section :content, '#content' do
    element :header, 'h1', text: 'New scheme templates'
  end
end
