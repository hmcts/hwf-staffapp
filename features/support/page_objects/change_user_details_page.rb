class ChangeUserDetailsPage < BasePage
  set_url '/edit'

  section :content, '#content' do
    element :header, 'h1', text: 'Change details'
    elements :radio, '.govuk-radios__item'
    element :reader_radio, '.govuk-radios__item', text: 'Reader'
    element :role, 'p', text: 'Manager'
    element :county_radio, '.govuk-radios__item', text: 'County'
  end
end
