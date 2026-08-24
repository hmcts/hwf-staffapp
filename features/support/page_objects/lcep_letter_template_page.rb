class LCEPLetterTemplatePage < BasePage
  set_url '/lcep_letter_templates'

  section :content, '#content' do
    element :header, 'h1', text: "Lord Chancellor's Exceptional Power letter templates"
  end
end
