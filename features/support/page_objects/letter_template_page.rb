class LetterTemplatePage < BasePage
  set_url '/letter_templates'

  section :content, '#content' do
    element :header, 'h1', text: 'Old scheme templates'
  end
end
