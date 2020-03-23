class ChangeUserDetailsPage < BasePage
  set_url '/edit'

  section :content, '#content' do
    element :header, 'h1', text: 'Change details'
    elements :jurisdiction_option, '.govuk-radios__item'
    element :user_radio, '.govuk-radios__item', text: 'User'
    element :manager_radio, '.govuk-radios__item', text: 'Manager'
    element :admin_radio, '.govuk-radios__item', text: 'Admin'
    element :mi_radio, '.govuk-radios__item', text: 'Mi'
    element :reader_radio, '.govuk-radios__item', text: 'Reader'
    element :role, 'p', text: 'Manager'
  end
end
