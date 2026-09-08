class AppealsLetterTemplatePage < BasePage
  set_url '/appeals_letter_templates'

  section :content, '#content' do
    element :header, 'h1', text: 'Appeals letter templates'
  end
end
