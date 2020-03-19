class ChangeProfileDetailsPage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'Change details'
    elements :jurisdiction_option, '.govuk-radios__item'
    element :reader_radio, '.govuk-label', text: 'Reader'
  end
end
